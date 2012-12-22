set linesize 150

column type format a15
column status format a80

select sid, serial#, type, status 
from v$logstdby_process
order by type;

select applied_scn, applied_sequence#, to_char(applied_time, 'DD/MM/YYYY HH24:MI:SS') applied_time 
from dba_logstdby_progress
order by applied_scn;

column thread# format 99999
column sequence# format 999999

select
  thread#, sequence#, first_change#, to_char(first_time, 'DD/MM/YYYY HH24:MI:SS') first_time,
  next_change#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') next_time, file_name, applied 
from
  dba_logstdby_log
where
  applied = 'NO'
  or next_time >= trunc(sysdate)
order by 
  thread#, sequence#;

column value format a20

select * 
from v$dataguard_stats;
