set linesize 150
set pages 9999
column status format a15

break on inst_id skip 1 on process

select inst_id, process, status, thread#, sequence#, delay_mins, known_agents, active_agents 
from gv$managed_standby 
order by inst_id, process, thread#;

column value format a18
column datum_time format a20
column time_computed format a20

select *
from v$dataguard_stats;
