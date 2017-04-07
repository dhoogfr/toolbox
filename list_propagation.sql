set linesize 300
set pages 50000

-- propagations
column propagation_name format a30
column source_queue_owner format a20
column source_queue_name format a30
column destination_queue_owner format a20
column destination_queue_name format a30
column destination_dblink format a30
column queue_to_queue format a10
column status format a10
column error_date_str format a20
column acked_scn format 999999999999999

select
  propagation_name, 
  source_queue_owner, 
  source_queue_name, 
  destination_queue_owner, 
  destination_queue_name, 
  destination_dblink, 
  queue_to_queue,
  acked_scn,
  status,
  to_char(error_date, 'DD/MM/YYYY HH24:MI:SS') error_date_str
from
  dba_propagation
order by
  propagation_name,
  source_queue_owner, 
  source_queue_name, 
  destination_queue_owner, 
  destination_queue_name
;
