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
set verify off
set feedback off

prompt Enter the begindate in the format DD/MM/YYYY HH24:MI
accept start_time prompt 'begin date: '

prompt Enter the enddate in the format DD/MM/YYYY HH24:MI
accept end_time prompt 'end date: '

prompt Enter the spoolfile
accept spoolfile prompt 'spool file: '

spool &spoolfile

WITH p as
 ( select dbid, instance_number, snap_id,
          lag(snap_id, 1, snap_id) over
            ( partition by dbid, instance_number
              order by snap_id
            ) prev_snap_id,
          begin_interval_time, end_interval_time          
   from dba_hist_snapshot
   where begin_interval_time between
            to_timestamp ('&start_time', 'DD/MM/YYYY HH24:MI') 
            and to_timestamp ('&end_time', 'DD/MM/YYYY HH24:MI')
 ),
 s as
 ( select d.name database, p.dbid, p.instance_number, p.prev_snap_id bsnap_id, p.snap_id esnap_id, 
          p.begin_interval_time bsnap_time, p.end_interval_time esnap_time, bs.stat_name,
          round((es.value-bs.value)/(   extract(second from (p.end_interval_time - p.begin_interval_time))
                                      + extract(minute from (p.end_interval_time - p.begin_interval_time)) * 60
                                      + extract(hour   from (p.end_interval_time - p.begin_interval_time)) * 60 * 60
                                      + extract(day    from (p.end_interval_time - p.begin_interval_time)) * 24 * 60 * 60
                                    )
                ,6
               ) valuepersecond
   from v$database d, p,
        dba_hist_sysstat bs, dba_hist_sysstat es
   where d.dbid = p.dbid
         and ( p.dbid = bs.dbid
               and p.instance_number = bs.instance_number
               and p.prev_snap_id = bs.snap_id
             )
         and ( p.dbid = es.dbid
               and p.instance_number = es.instance_number
               and p.snap_id = es.snap_id
             )
         and ( bs.stat_id = es.stat_id
               and bs.stat_name=es.stat_name
             )
         and bs.stat_name in
           ( 'redo size','redo blocks written','session logical reads','db block changes','physical reads','physical writes','user calls',
             'parse count (total)','parse count (hard)','sorts (memory)','sorts (disk)','logons cumulative','execute count','user rollbacks',
             'user commits', 'recursive calls','sorts (rows)','CPU used by this session','recursive cpu usage','parse time cpu',
             'rollback changes - undo records applied'
           )
 ),
g as
 ( select /*+ FIRST_ROWS */
          database, instance_number,  bsnap_id, esnap_id, bsnap_time, esnap_time,
          sum(decode( stat_name, 'redo size'                               , valuepersecond, 0 )) redo_size,
          sum(decode( stat_name, 'redo blocks written'                     , valuepersecond, 0 )) redo_blocks,
          sum(decode( stat_name, 'session logical reads'                   , valuepersecond, 0 )) logical_reads,
          sum(decode( stat_name, 'db block changes'                        , valuepersecond, 0 )) block_changes,
          sum(decode( stat_name, 'physical reads'                          , valuepersecond, 0 )) physical_reads ,
          sum(decode( stat_name, 'physical writes'                         , valuepersecond, 0 )) physical_writes,
          sum(decode( stat_name, 'user calls'                              , valuepersecond, 0 )) user_calls,
          sum(decode( stat_name, 'recursive calls'                         , valuepersecond, 0 )) recursive_calls,
          sum(decode( stat_name, 'parse count (total)'                     , valuepersecond, 0 )) parses ,
          sum(decode( stat_name, 'parse count (hard)'                      , valuepersecond, 0 )) hard_parses ,
          sum(decode( stat_name, 'sorts (rows)'                            , valuepersecond, 0 )) sort_rows ,
          sum(decode( stat_name, 'sorts (memory)'                          , valuepersecond,
                                 'sorts (disk)'                            , valuepersecond, 0 )) sorts  ,
          sum(decode( stat_name, 'logons cumulative'                       , valuepersecond, 0 )) logons ,
          sum(decode( stat_name, 'execute count'                           , valuepersecond, 0 )) executes ,
          sum(decode( stat_name, 'user rollbacks'                          , valuepersecond,
                                 'user commits'                            , valuepersecond, 0 )) transactions,
          sum(decode( stat_name, 'user rollbacks'                          , valuepersecond, 0 )) rollbacks,
          sum(decode( stat_name, 'rollback changes - undo records applied' , valuepersecond, 0 )) undo_records,
          sum(decode( stat_name, 'CPU used by this session'                , valuepersecond/100, 0 )) cpusecs,
          sum(decode( stat_name, 'recursive cpu usage'                     , valuepersecond/100, 0 )) rec_cpusecs,
          sum(decode( stat_name, 'parse time cpu'                          , valuepersecond/100, 0 )) parse_cpusecs
 from s
 group by database,instance_number, bsnap_id, esnap_id, bsnap_time, esnap_time
 )
select instance_number, bsnap_id, to_char(bsnap_time,'DD-MON-YY HH24:MI') bsnap_time, esnap_id, to_char(esnap_time,'DD-MON-YY HH24:MI') esnap_time, redo_blocks, logical_reads, block_changes, physical_reads,
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

spool off

set feedback on
