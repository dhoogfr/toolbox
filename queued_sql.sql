break on sql_text on sql_id
col sql_text for a60 trunc

select
  inst_id, sid, sql_id, sql_exec_id, sql_text, queuing_time
from
  gv$sql_monitor
where
  status='QUEUED'
order by
  sql_id
;

clear break
