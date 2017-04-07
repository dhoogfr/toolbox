set linesize 300
set pages 50000


column source_database format a15
column error_message format a100 word_wrapped
column rror_crea_time_str format a20
column message_count format 9G999G999

break on apply_name skip page

select
  apply_name, 
  source_database, 
  local_transaction_id,
  message_count,
  error_type,
  to_char(error_creation_time, 'DD/MM/YYYY HH24:MI:SS') error_crea_time_str,
  error_message
from
  dba_apply_error
order by
  apply_name,
  error_creation_time
;

clear breaks
