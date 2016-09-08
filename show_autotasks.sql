-- show information regarding the autotasks and their windows

set linesize 250

column client_name format a35 heading "Client Name"
column task_name format a25 heading "Task Name"
column operation_name format a30 heading "Operation Name"
column status format a10 heading "Status"
column current_job_name format a25 heading "Current Job Name"
column last_good_date_str format a26 heading "Last Good Date"
column last_try_date_str format a26 heading "Last Try Date"
column next_try_date_str format a26 heading "Next Try Date"
column last_good_duration_str format a12 heading "Last Good|Duration"
column mean_good_duration_str format a12 heading "Mean Good|Duration"

column client_tag format a10 heading "Client|Tag"
column consumer_group format a30 heading "Consumer Group"
column window_group format a20 heading "Window Group"
column service_name format a30 heading "Service Name"
column last_change_str format a30 heading "Last Change"

column operation_tag format a10 heading "Operation|Tag"
column attributes format a55 heading "Attributes"
column use_resource_estimates format a10 heading "Resource|Estimates"
column priority_override format a10 heading "Priority|Override"

column window_name format a20 heading "Window Name"
column window_next_time_str format a30 heading "Next Time"
column window_active format a6 heading "Active"
column autotask_status format a11 heading "Task Status"
column optimizer_stats format a10 heading "Optimizer|Status"
column segment_advisor format a10 heading "Segment|Advisor"
column sql_tune_advisor format a10 heading "SQL Tune|Advisor"
column health_monitor format a10 heading "Health|Monitor"

column window_start_time_str format a30 heading "Start Time"
column window_end_time_str format a30 heading "End Time"
column duration format a30 heading "Duration"

column task_target_type format a30 heading "Target Type"
column task_target_name format a50 heading "Target Name"
column task_priority format a10 heading "Priority"
column job_scheduler_status format a15 heading "Job Status"

column job_duration format a15 heading "Duration"
column job_start_time format a30 heading "Start Time"
column job_status format a10 heading "Status"
column job_error format 99999999 heading "Error"

prompt
prompt Defined Autotask Operations
prompt ===========================
prompt

prompt autotask task:

select 
  client_name, 
  task_name, 
  operation_name, 
  status, 
  current_job_name, 
  to_char(last_good_date, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') last_good_date_str,
  ( to_char(decode(last_good_duration, 0, 0, extract(day from (systimestamp + numtodsinterval(last_good_duration,'second') - systimestamp))), 'FM990') || ' ' ||
    to_char(decode(last_good_duration, 0, 0, extract(hour from (systimestamp + numtodsinterval(last_good_duration,'second') - systimestamp))), 'FM00') || ':' ||
    to_char(decode(last_good_duration, 0, 0, extract(minute from (systimestamp + numtodsinterval(last_good_duration,'second') - systimestamp))), 'FM00') || ':' ||
    to_char(decode(last_good_duration, 0, 0, floor(extract(second from (systimestamp + numtodsinterval(last_good_duration,'second') - systimestamp)))), 'FM00')
  ) last_good_duration_str,
  ( to_char(decode(mean_good_duration, 0, 0, extract(day from (systimestamp + numtodsinterval(mean_good_duration,'second') - systimestamp))), 'FM990') || ' ' ||
    to_char(decode(mean_good_duration, 0, 0, extract(hour from (systimestamp + numtodsinterval(mean_good_duration,'second') - systimestamp))), 'FM00') || ':' ||
    to_char(decode(mean_good_duration, 0, 0, extract(minute from (systimestamp + numtodsinterval(mean_good_duration,'second') - systimestamp))), 'FM00') || ':' ||
    to_char(decode(mean_good_duration, 0, 0, floor(extract(second from (systimestamp + numtodsinterval(mean_good_duration,'second') - systimestamp)))), 'FM00')
  ) mean_good_duration_str,
  to_char(last_try_date, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') last_try_date_str, 
  to_char(next_try_date, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') next_try_date_str
from
  dba_autotask_task
order by
  client_name
;

prompt autotask client:

select 
  client_name, 
  client_tag, 
  status, 
  consumer_group, 
  window_group, 
  service_name, 
  to_char(last_change, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') last_change_str 
from
  dba_autotask_client 
order by 
  client_name
;

prompt autotask operation:

select
  client_name, 
  operation_name,
  operation_tag,
  priority_override,
  attributes,
  use_resource_estimates,
  status,
  to_char(last_change, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') last_change_str
from
  dba_autotask_operation
order by
  client_name
;


prompt
prompt Autotask Windows
prompt ================
prompt

select
  window_name,
  to_char(window_next_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') window_next_time_str,
  window_active,
  autotask_status,
  optimizer_stats,
  segment_advisor,
  sql_tune_advisor,
  health_monitor
from
  dba_autotask_window_clients
order by
  window_next_time
;


prompt
prompt Autotask Window History
prompt =======================
prompt

select
  to_char(window_start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') window_start_time_str,
  to_char(window_end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') window_end_time_str,
  nvl2(window_end_time, window_end_time - window_start_time, null) duration,
  window_name 
from
  dba_autotask_window_history 
order by 
  window_start_time
;


prompt
prompt Autotask client History
prompt =======================
prompt


break on window_start_time_str on window_end_time_str on duration on window_name skip 1

select 
  window_name, 
  to_char(window_start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') window_start_time_str,
  to_char(window_end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM')   window_end_time_str,
  window_duration                                             duration, 
  client_name, 
  jobs_created, 
  jobs_started, 
  jobs_completed 
from 
  dba_autotask_client_history 
order by 
  window_start_time,
  window_name, 
  client_name
;

clear breaks


prompt
prompt Current Running Autotasks
prompt =========================
prompt


select
  client_name, 
  task_name, 
  task_target_type, 
  task_target_name, 
  task_priority, 
  task_operation, 
  job_name, 
  job_scheduler_status 
from
  dba_autotask_client_job 
order by 
  client_name
;


prompt
prompt Last 10 Job Runs Per Autotask
prompt =============================
prompt

break on client_name skip 1

select
  client_name, 
  to_char(job_start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') job_start_time_str, 
  job_duration, 
  job_status, 
  job_error
from
  ( select
      client_name, 
      job_status, 
      job_start_time, 
      job_duration, 
      job_error,
      row_number () over
        ( partition by client_name
          order by job_start_time desc
        ) rn
    from
      dba_autotask_job_history 
  )
where
  rn <= 10
order by 
  client_name, 
  job_start_time
;

clear breaks
