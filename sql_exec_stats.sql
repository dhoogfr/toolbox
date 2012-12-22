-- list execution statistics about a sql statement

set linesize 150
column first_load_time format a20
column child_number format 999 heading CN

select
  sql_id, child_number, plan_hash_value, to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS') now, 
  first_load_time, fetches, executions, disk_reads, buffer_gets, 
  rows_processed, elapsed_time
from
  v$sql
where
  sql_id = '&sql_id'
order by
  sql_id,
  child_number
;
