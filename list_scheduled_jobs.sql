-- list the scheduled jobs

set linesize 170
column owner format a15
column state format a10
column failure_count format 999 heading FC
column run_count format 99999 heading RC
column job_name format a28
column next_run_date format a35
column last_start_date format a35
column job_class format a30

select
  owner, job_name, state, run_count, failure_count, 
  to_char(last_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') last_start_date, 
  to_char(next_run_date, 'DD/MM/YYYY HH24:MI:SS TZR') next_run_date,
  job_class
from
  dba_scheduler_jobs
order by
  owner, job_name
;

