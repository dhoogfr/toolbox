-- list the execution details for a given job.
-- parameters asked for are the job owner, the job name and the number of past executions that need to be listed

set linesize 250

column log_date format a20
column req_start_date format a35
column actual_start_date format a35
column run_duration format a14
column status format a10
column owner format a15
column job_name format a28

select
  instance_id,
  -- to_char(log_date, 'DD/MM/YYYY HH24:MI:SS') log_date, 
  to_char(req_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') req_start_date, 
  to_char(actual_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') actual_start_date, 
  run_duration, status, error#
from 
  ( select
      owner, job_name, instance_id, log_date, req_start_date, actual_start_date, 
      run_duration, status, error#,
      row_number () over
        ( partition by owner, job_name
          order by log_date desc
        ) rn
    from
      dba_scheduler_job_run_details
    where
      owner = '&job_owner'
      and job_name = '&job_name'
  ) jrd
where
  rn <= &nbr_executions    
order by 
  jrd.log_date desc
;

undef job_owner
undef job_name
undef nbr_executions
