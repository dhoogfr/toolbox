set pages 0
set lines 132
set pause off
set feedback off
set verify off
col dsnbr noprint

/* is the archiver falling behind, count should be 1 or 0 */
select decode(count(*),0,'Archiver is current',
               1,'Archiver is archiving ' || count(*) || ' log...',
               'Archiver has fallen behind by ' || count(*) || ' logs!')
  from v$log 
 where status != 'CURRENT'
   and archived = 'NO';

/* what is the current log  COL:<ufs mt pt>:<log name>:<seq #>:<# members> */
select 'Current Online Log:' || chr(9) ||
       substr(f.member,1,(instr(f.member,'/',1,2) -1)) 
       || '/.../' ||
       substr(f.member,(instr(f.member,'/',-1,1)+1))
       || chr(9) || 'Sequence #' ||
       l.sequence#
  from v$logfile f, v$log l
 where l.group# = f.group#
   and l.status = 'CURRENT'
   and l.archived = 'NO'
   and rownum = 1;

/* what are the previous online logs */
select lc_1.sequence# dsnbr,
       'Previous Online Logs:' || chr(9) ||
       substr(f.member,1,(instr(f.member,'/',1,2) -1)) 
       || '/.../' ||
       substr(f.member,(instr(f.member,'/',-1,1)+1))
       || chr(9) || 'Sequence #' ||
       lc_1.sequence#
  from v$log lc, v$log lc_1, v$logfile f
 where lc.sequence# = (select max(l.sequence#) from v$log l)
   and lc_1.sequence# = lc.sequence# -1
   and f.group# = lc_1.group#
union
select lc_2.sequence# dsnbr,
       '                  ' || chr(9) ||
       substr(f.member,1,(instr(f.member,'/',1,2) -1)) 
       || '/.../' ||
       substr(f.member,(instr(f.member,'/',-1,1)+1))
       || chr(9) || 'Sequence #' ||
       lc_2.sequence#
  from v$log lc, v$log lc_2, v$logfile f
 where lc.sequence# = (select max(l.sequence#) from v$log l)
   and lc_2.sequence# = lc.sequence# -2
   and f.group# = lc_2.group#
union
select lc_3.sequence# dsnbr,
       '                  ' || chr(9) ||
       substr(f.member,1,(instr(f.member,'/',1,2) -1)) 
       || '/.../' ||
       substr(f.member,(instr(f.member,'/',-1,1)+1))
       || chr(9) || 'Sequence #' ||
       lc_3.sequence#
  from v$log lc, v$log lc_3, v$logfile f
 where lc.sequence# = (select max(l.sequence#) from v$log l)
   and lc_3.sequence# = lc.sequence# -3
   and f.group# = lc_3.group#
order by 1 desc;

/* what is the latest archived log LAL:<archlog name>:<seq #> */
select 'Latest Archived Log:' || chr(9) ||
       substr(h.name,(instr(h.name,'/',-1,1)+1))
       || chr(9) || 'Sequence #' || 
       max(h.sequence#)
  from v$archived_log h
 where h.sequence# = (select max(l.sequence#)
                         from v$log l
                 where l.archived = 'YES'
                   and l.status = 'INACTIVE')
group by 'Latest Archived Log:' || chr(9) ||
         substr(h.name,(instr(h.name,'/',-1,1)+1));

/* how many minutes since the last log switch MSL:<elapsed minutes> */
select 'Elapsed Minutes Since Last Log Switch:' || chr(9) ||
       trunc((sysdate - first_time) * 24 * 60)
from v$log
where status = 'CURRENT'
and sequence# = (select max(sequence#) + 1
           from v$log_history);

/* what are the last 3 individual switch intervals L3I:<1>:<2>:<3> */
select 'Prior 3 Actual Switch Intervals:' || chr(9) || '[' || 
   round((lc.first_time - lc_1.first_time) * 24 * 60,2) 
   || ']' || chr(9) || '[' ||
   round((lc_1.first_time - lc_2.first_time) * 24 * 60,2)
   || ']' || chr(9) || '[' ||
   round((lc_2.first_time - lc_3.first_time) * 24 * 60,2)
   || ']'
from v$log lc, v$log_history lc_1, v$log_history lc_2, v$log_history lc_3
where lc.sequence# = (select max(l.sequence#) from v$log l)
and lc_1.sequence# = lc.sequence# -1
and lc_2.sequence# = lc.sequence# -2
and lc_3.sequence# = lc.sequence# -3;

/* what is the avg interval for last 3 log switches L3S:<minutes> */
select 'Prior 3 Average Switch Interval:' || chr(9) || 
round( (
   round((lc.first_time - lc_1.first_time) * 24 * 60,2) +
   round((lc_1.first_time - lc_2.first_time) * 24 * 60,2) +
   round((lc_2.first_time - lc_3.first_time) * 24 * 60,2) ) / 3, 1)
from v$log lc, v$log_history lc_1, v$log_history lc_2, v$log_history lc_3
where lc.sequence# = (select max(l.sequence#) from v$log l)
and lc_1.sequence# = lc.sequence# -1
and lc_2.sequence# = lc.sequence# -2
and lc_3.sequence# = lc.sequence# -3;

set pages 24
