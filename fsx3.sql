set verify off
set pagesize 999
set lines 190
col sql_text format a20 trunc
col child format 99999 
col execs format 9,999
col avg_etime format 9,999,999.99
col avg_cpu  format 9,999,999.99
col avg_lio format 999,999,999
col avg_pio format 999,999,999
col "IO_SAVED_%" format 999.99
col avg_px format 999
col offload for a7

select sql_id, child_number child, 
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
executions execs,
IO_CELL_OFFLOAD_ELIGIBLE_BYTES eligible_bytes, sql_text 
from v$sql s
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like 'BEGIN :sql_text := %'
and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%'
and sql_id like nvl('&sql_id',sql_id)
order by 1, 2, 3
/
