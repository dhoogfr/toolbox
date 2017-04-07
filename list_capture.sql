set linesize 300
set pages 50000

column capture_name format a30
column queue_name format a30
column status format a10
column capture_type format a30
column rule_set_name format a25
column negative_rule_set_name format a25
column captured_scn format 999999999999999
column applied_scn format 999999999999999
column filtered_scn format 999999999999999
column last_enqueued_scn format 999999999999999

select
  capture_name, 
  queue_name, 
  status, 
  start_time,
  capture_type, 
  rule_set_name, 
  negative_rule_set_name,
  captured_scn,
  applied_scn,
  filtered_scn,
  last_enqueued_scn
from
  dba_capture
;
