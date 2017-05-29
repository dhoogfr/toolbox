set linesize 250
column bundle_series format a15
column status format a15
column description format a65
column action_time format a20

select
  to_char(action_time, 'DD/MM/YYYY HH24:MI') action_time_str,
  bundle_series,
  patch_id, 
  patch_uid, 
  version, status, 
  description
from
  dba_registry_sqlpatch
order
  by action_time,
  bundle_series,
  patch_id
;
