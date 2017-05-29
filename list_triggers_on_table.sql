column trigger_name format a30
column trigger_type format a30
column triggering_event format a30
column trigger_body format a200
column table_name format a30

break on trigger_name skip page


select
  table_name,
  trigger_name,
  trigger_type,
  triggering_event,
  status,
  trigger_body 
from
  dba_triggers
where
  owner = '&owner' 
  and table_name = '&table_name'
order by
  table_name, 
  trigger_name, 
  trigger_type
;


clear breaks

undef owner
undef table_name