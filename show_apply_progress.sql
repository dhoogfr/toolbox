-- Apply Coordinator information and apply progress
set linesize 250
set pages 50000

column apply_name format a30
column total_received format 9G999G999G999
column total_applied format 9G999G999G999
column total_errors format 9G999G999G999

prompt
prompt Coordinator Info
prompt ================
prompt

 select
  inst_id,
  sid,
  serial#,
  apply_name,
  state,
  total_received,
  total_applied,
  total_errors
from
  gv$streams_apply_coordinator
order by
  apply_name
;


prompt
prompt Apply Progress
prompt ==============
prompt

column apply_name format a30
column source_database format a15
column applied_message_number format 99999999999999999
column applied_msg_crea_time format a20
column applied_message_time format a20


select
  apply_name,
  source_database,
  applied_message_number,
  to_char(applied_message_create_time, 'DD/MM/YYYY HH24:MI:SS') applied_msg_crea_time,
  to_char(apply_time, 'DD/MM/YYYY HH24:MI:SS') applied_message_time
from
  dba_apply_progress
order by apply_name
;
