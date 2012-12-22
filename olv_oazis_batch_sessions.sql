column machine format a20
column osuser format a15

select
  sid, serial#, machine, osuser, to_char(logon_time, 'DD/MM/YYYY HH24:MI') logon_time, 
  last_call_et, sql_id, sql_trace, sql_trace_binds, sql_trace_waits, sql_trace_plan_stats
from
  v$session
where
  service_name = 'oazis_batch'
order by
  v$session.logon_time desc
;
