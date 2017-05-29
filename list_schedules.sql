-- list information on the job scheduler schedules

set linesize 240
set pages 50000

column owner format a30
column schedule_name format a30
column str_start_date format a40
column repeat_interval format a80

select
  owner, 
  schedule_name, 
  schedule_type, 
  to_char(start_date, 'DD/MM/YYYY HH24:MI:SS TZR') str_start_date,
  repeat_interval 
from
  dba_scheduler_schedules
order by
  owner,
  schedule_name
;


