select
  prc.spid, ses.sid, ses.serial#, ses.machine, ses.osuser, to_char(ses.logon_time, 'DD/MM/YYYY HH24:MI') logon_time,
  ses.last_call_et, ses.sql_id, ses.sql_trace, ses.sql_trace_binds, ses.sql_trace_waits, ses.sql_trace_plan_stats
from
  v$process     prc,
  v$session     ses
where
  ses.paddr = prc.addr
  and ses.sid = &sid
;
