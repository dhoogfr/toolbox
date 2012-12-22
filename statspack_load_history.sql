/* when using statspack, this query shows the statspack summary (same values as 'Load Profile' in statspack report)
   for each snapshot during the last week.

   Thus you can quickly check the database load history and then run statspack report on desired snap_id if you want further details.
   
   It shows following columns for each timestamp:
   
      Redo size (in blocks) per second
      Logical reads per second
      Block changes per second
      Physical reads per second (disk io/secs)
      Physical writes per second
      User calls per second
      Parses per second
      Hard parses per second
      Sorts per second
      Logons per second
      Executes per second
      Transactions per second
      Blocks changed per Read %
      Recursive Call %
      Rollback per transaction %
      Rows per Sort %
      cpu per elapsed %
      Buffer hit ratio %
   
   This query shows history for the seven last days.
   You can modify it on the first lines 
*/

set linesize 400
set pagesize 9999
alter session set nls_numeric_characters=',.';
set trimspool on

WITH p as
 ( select dbid, instance_number, snap_id,
          lag(snap_id, 1, snap_id) over
            ( partition by dbid, instance_number
              order by snap_id
            ) prev_snap_id,
          lag(snap_time, 1, snap_time) over
            ( partition by dbid, instance_number
              order by snap_id
            ) begin_interval_time, 
          snap_time end_interval_time          
   from stats$snapshot
   where snap_time between
            to_timestamp ('15/09/2008 00:00', 'DD/MM/YYYY HH24:MI') and to_timestamp ('04/10/2008 00:00', 'DD/MM/YYYY HH24:MI')
 ),
 s as
 ( select d.name database, p.dbid, p.instance_number, p.prev_snap_id bsnap_id, p.snap_id esnap_id, p.end_interval_time bsnap_time,
          p.end_interval_time esnap_time, bs.name,
          round((es.value-bs.value)/((p.end_interval_time - p.begin_interval_time) * 24 * 60 * 60),6) valuepersecond
   from v$database d, p,
        stats$sysstat bs, stats$sysstat es
   where d.dbid = p.dbid
         and ( p.dbid = bs.dbid
               and p.instance_number = bs.instance_number
               and p.prev_snap_id = bs.snap_id
             )
         and ( p.dbid = es.dbid
               and p.instance_number = es.instance_number
               and p.snap_id = es.snap_id
             )
         and ( bs.statistic# = es.statistic#
               and bs.name = es.name
             )
         and bs.name in
           ( 'redo size','redo blocks written','session logical reads','db block changes','physical reads','physical writes','user calls',
             'parse count (total)','parse count (hard)','sorts (memory)','sorts (disk)','logons cumulative','execute count','user rollbacks',
             'user commits', 'recursive calls','sorts (rows)','CPU used by this session','recursive cpu usage','parse time cpu',
             'rollback changes - undo records applied'
           )
         and p.snap_id != p.prev_snap_id
 ),
g as
 ( select database, instance_number, bsnap_time,
          sum(decode( name, 'redo size'                               , valuepersecond, 0 )) redo_size,
          sum(decode( name, 'redo blocks written'                     , valuepersecond, 0 )) redo_blocks,
          sum(decode( name, 'session logical reads'                   , valuepersecond, 0 )) logical_reads,
          sum(decode( name, 'db block changes'                        , valuepersecond, 0 )) block_changes,
          sum(decode( name, 'physical reads'                          , valuepersecond, 0 )) physical_reads ,
          sum(decode( name, 'physical writes'                         , valuepersecond, 0 )) physical_writes,
          sum(decode( name, 'user calls'                              , valuepersecond, 0 )) user_calls,
          sum(decode( name, 'recursive calls'                         , valuepersecond, 0 )) recursive_calls,
          sum(decode( name, 'parse count (total)'                     , valuepersecond, 0 )) parses ,
          sum(decode( name, 'parse count (hard)'                      , valuepersecond, 0 )) hard_parses ,
          sum(decode( name, 'sorts (rows)'                            , valuepersecond, 0 )) sort_rows ,
          sum(decode( name, 'sorts (memory)'                          , valuepersecond,
                            'sorts (disk)'                            , valuepersecond, 0 )) sorts  ,
          sum(decode( name, 'logons cumulative'                       , valuepersecond, 0 )) logons ,
          sum(decode( name, 'execute count'                           , valuepersecond, 0 )) executes ,
          sum(decode( name, 'user rollbacks'                          , valuepersecond,
                            'user commits'                            , valuepersecond, 0 )) transactions,
          sum(decode( name, 'user rollbacks'                          , valuepersecond, 0 )) rollbacks,
          sum(decode( name, 'rollback changes - undo records applied' , valuepersecond, 0 )) undo_records,
          sum(decode( name, 'CPU used by this session'                , valuepersecond/100, 0 )) cpusecs,
          sum(decode( name, 'recursive cpu usage'                     , valuepersecond/100, 0 )) rec_cpusecs,
          sum(decode( name, 'parse time cpu'                          , valuepersecond/100, 0 )) parse_cpusecs
 from s
 group by database,instance_number, bsnap_time
 )
select to_char(bsnap_time,'DD-MON-YY HH24:MI') snap_time, instance_number, redo_blocks, logical_reads, block_changes, physical_reads,
       physical_writes, user_calls, parses, hard_parses, sorts, logons, executes, transactions,
       to_char(100 * (block_changes / decode(logical_reads,0,1,logical_reads)),'909D90')||'%' changes_per_read,
       to_char(100 * (recursive_calls / decode(user_calls + recursive_calls, 0, 1,user_calls + recursive_calls)),'909D90') ||'%' recursive,
       to_char(100 * (rollbacks / decode(transactions,0,1,transactions)),'909D90') ||'%' rollback,
       to_char(decode(sorts, 0, NULL, (sort_rows/sorts)),'999999') rows_per_sort,
       100 * cpusecs cpusecs_pct,
       100 * rec_cpusecs rec_cpusecs_pct,
       100 * parse_cpusecs parse_cpusecs_pct,
       to_char(100 * (1 - physical_reads / decode(logical_reads, 0, 1,logical_reads)),'909D90') ||'%' buffer_hit,
       undo_records, rollbacks
from g
order by instance_number, bsnap_time;