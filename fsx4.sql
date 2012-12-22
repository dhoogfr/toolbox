set verify off
set pagesize 999
set lines 190
col sql_text format a40 trunc
col child format 99999 heading CHILD
col execs format 9,999,999
col avg_etime format 99,999.99
col avg_cpu  format 9,999,999.99
col avg_lio format 999,999,999
col avg_pio format 999,999,999
col "IO_SAVED_%" format 999.99
col avg_px format 999
col offload for a7

select sql_id, child_number child, 
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,
100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
/decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%",
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, 
--decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,buffer_gets/decode(nvl(executions,0),0,1,executions),null) avg_lio,
--decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,disk_reads/decode(nvl(executions,0),0,1,executions),null) avg_pio,
sql_text 
from v$sql s
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like 'BEGIN :sql_text := %'
and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%'
and sql_id like nvl('&sql_id',sql_id)
order by 1, 2, 3
/
