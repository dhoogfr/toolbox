----------------------------------------------------------------------------------------
--
-- File name:   offload_percent.sql
--
-- Purpose:     Caclulate % of long running statements that were offloaded. 
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values.
--
--              sql_text: a piece of a SQL statement like %select col1, col2 from skew%
--                        The default is to return all statements.
--
--              min_etime: the minimum avg. elapsed time in seconds
--                         This parameter allows limiting the output to long running statements.
--                         The default is 0 which returns all statements.
--
--              min_avg_lio: the minimum avg. elapsed time in seconds
--                           This parameter allows limiting the output to long running statements.
--                           The default is 500,000.
--
-- Description:
--
--              This script can be used to provide a quick check on whether statements 
--              are being offloaded or not on Exadata platforms.
--
--              It is based on the observation that the IO_CELL_OFFLOAD_ELIGIBLE_BYTES
--              column in V$SQL is only greater than 0 when a statement is executed
--              using a Smart Scan. 
--
--              The default values will aggregate data for all statements that have an
--              avg_lio value of greater than 500,000. You can change this minimum value
--              or further limit the set of statements that will be evaluated by providing
--              a piece of SQL text, 'select%' for example, or setting a minimum avg. 
--              elapsed time value. 
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
set pagesize 999
set lines 190
col sql_text format a70 trunc
col child format 99999
col execs format 9,999
col avg_etime format 99,999.99
col "OFFLOADED_%" format a11
col avg_px format 999
col offload for a7

select 
offloaded+not_offloaded total, offloaded, 
lpad(to_char(round(100*offloaded/ (offloaded+not_offloaded),2))||'%',11,' ') "OFFLOADED_%" 
from (
select sum(decode(offload,'Yes',1,0)) offloaded, 
       sum(decode(offload,'No',1,0)) not_offloaded
from (
select * from (
select sql_id, child_number child, plan_hash_value plan_hash, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)/
decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_etime, 
px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_px,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
/decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%",
-- buffer_gets lio,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like 'BEGIN :sql_text := %'
and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%')
where avg_etime > nvl('&min_etime','0')
)
where avg_lio > nvl('&min_avg_lio','500000')
)
/
