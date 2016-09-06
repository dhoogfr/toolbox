column status format a15
column description format a60

select
  patch_id, 
  patch_uid, 
  version, status, 
  description
from
  dba_registry_sqlpatch
order
  by bundle_series
;
