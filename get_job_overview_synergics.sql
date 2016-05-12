/* Give an overview of the jobs in dba_jobs, scheduler_jobs and autotask jobs
*/
clear breaks
set pagesize 9999
set serveroutput on
set trimspool on
set echo off
set feedback 1

----------------------------------------- the following bit is added for Synergics
----------------------------------------- either specify a logfile name yourself or one will be generated for you

set verify off
set feedback off
column dcol new_value spoolname noprint
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;

select
  nvl('&1', db_unique_name || '_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '_job_overview.log') dcol 
from 
  v$database
;

undefine 1

spool &spoolname

-- db and platform identification
prompt
prompt DB IDENTIFICATION
prompt ------------------

set linesize 200
column platform_name format a40
column name format a15
column db_unique_name format a20

select
  dbid, name, db_unique_name, database_role, platform_name 
from
  v$database
;

column host_name format a40

select
  instance_number, instance_name, host_name, version
from 
  gv$instance
order by
  instance_number
;

prompt
prompt TIMEZONE AND TIMESTAMP INFO
prompt ----------------------------

column systimestamp format a50

select
  dbtimezone, systimestamp
from
  dual
;

----------------------------------------- end synergics specific section


prompt
prompt
prompt JOBS
prompt -----

set linesize 200

column interval format a30 word_wrapped
column what format a50 word_wrapped
column failures format 999
column broken format a1
column schema_user format a20

select
  job, schema_user, what, last_date, last_sec, interval, broken, failures 
from
  dba_jobs
order by 
  job
;

prompt
prompt
prompt DEFINED SCHEDULER JOBS
prompt -----------------------

set linesize 150
column owner format a15
column state format a10
column failure_count format 999 heading FC
column run_count format 99999 heading RC
column job_name format a28
column next_run_date format a35
column last_start_date format a35

select
  owner, job_name, state, run_count, failure_count, 
  to_char(last_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') last_start_date, 
  to_char(next_run_date, 'DD/MM/YYYY HH24:MI:SS TZR') next_run_date
from
  dba_scheduler_jobs
order by
  owner, job_name
;

prompt
prompt
prompt LAST 10 RUNS PER SCHEDULER JOB
prompt -------------------------------

clear breaks
set linesize 150
column log_date format a20
column req_start_date format a35
column actual_start_date format a35
column run_duration format a14
column status format a10
column owner format a15
column job_name format a28
break on owner skip 1 on job_name skip 1

select
  owner, job_name, -- to_char(log_date, 'DD/MM/YYYY HH24:MI:SS') log_date, 
  to_char(req_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') req_start_date, 
  to_char(actual_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') actual_start_date, 
  run_duration, status
from 
  ( select
      owner, job_name, log_date, req_start_date, actual_start_date, 
      run_duration, status,
      row_number () over
        ( partition by owner, job_name
          order by log_date desc
        ) rn
    from
      dba_scheduler_job_run_details
    where
      job_name not like 'ORA$AT_%' -- filter out autotasks
  ) jrd
where
  rn <= 10      
order by 
  owner, job_name, jrd.log_date desc
;

prompt
prompt
prompt 10 MOST RECENT JOB RUNS
prompt ------------------------

clear breaks
set linesize 150
column start_date format a20
column run_duration format a14
column status format a10
column owner format a15
column job_name format a30

select
  to_char(actual_start_date, 'DD/MM/YYYY HH24:MI:SS') start_date,
  owner, job_name, run_duration, status
from 
  ( select 
      actual_start_date, owner, job_name, run_duration, status
    from
      dba_scheduler_job_run_details
    where
      job_name not like 'ORA$AT_%' -- filter out autotasks
    order by 
      actual_start_date desc
  ) jrd
where
  rownum <= 10
;

prompt
prompt
prompt DEFINED AUTOTASKS
prompt ------------------

clear breaks
column client_name format a35

select
  client_name, status 
from
  dba_autotask_operation 
order by
  client_name
;

prompt
prompt
prompt AUTOTASK WINDOWS
prompt -----------------

clear breaks
set linesize 150
column window_next_time format a45

select
  * 
from
  dba_autotask_window_clients
;

prompt
prompt
prompt LAST 10 RUNS PER AUTOTASK
prompt --------------------------

column client_name format a35
column job_duration format a14
column job_start_time format a45
column job_status format a10

break on client_name skip 1

select
  client_name, job_start_time, job_duration, job_status, job_error
from
  ( select
      client_name, job_status, job_start_time, job_duration, job_error,
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
  client_name, job_start_time desc
;

clear breaks

spool off
