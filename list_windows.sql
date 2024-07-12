-- list information on the job scheduler windows

set linesize 350
set pages 50000

column owner format a30
column window_name format a30
column repeat_interval format a70
column duration format a20
column str_start_date format a40
column str_next_start_date format a40
column resource_plan format a40

select
  owner,
  window_name,
  enabled,
  to_char(start_date, 'DD/MM/YYYY HH24:MI:SS TZR') str_start_date,
  repeat_interval,
  duration,
  to_char(next_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') str_next_start_date,
  resource_plan
from
  dba_scheduler_windows
order by
  owner,
  window_name
;

