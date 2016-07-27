column status format a15

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
