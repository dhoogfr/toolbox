column tracefile_name for a120

select
  value tracefile_name
from
  v$diag_info
where
  name = 'Default Trace File'
;
