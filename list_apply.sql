set linesize 300
set pages 50000

column apply_name format a30
column queue_name format a30
column queue_owner format a30
column rule_set_owner format a30
column rule_set_name format a20
column apply_user format a30
column apply_database_link format a20
column ddl_handler format a45
column status format a10
column status_change_time_str format a20
column error_number format 99999


select
  apply_name, 
--  queue_name, 
--  queue_owner, 
  apply_captured, 
  rule_set_name, 
  rule_set_owner, 
  apply_user, 
  apply_database_link, 
  ddl_handler, 
  status, 
  to_char(status_change_time, 'DD/MM/YYYY HH24:MI:SS') status_change_time_str, 
  error_number 
from
  dba_apply
order by
  apply_name
;
