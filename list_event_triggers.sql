-- list triggers where trigger_type is either after event or before event

set linesize 250

column owner format a30
column trigger_name format a30
column trigger_type format a30
column triggering_event format a30
column trigger_body format a200
column table_name format a30

break on trigger_name skip page


select
  owner,
  table_name,
  trigger_name,
  trigger_type,
  triggering_event,
  status,
  trigger_body 
from
  dba_triggers
where
  trigger_type in ('AFTER EVENT', 'BEFORE EVENT')
order by
  owner,
  trigger_type,
  triggering_event,
  table_name, 
  trigger_name
;


clear breaks
