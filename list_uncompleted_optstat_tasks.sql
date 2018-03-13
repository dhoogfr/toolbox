/* list the optimizer statistic operation tasks that are failed, timed out or skipped
   
   The script will ask for an optionally filter on the start time (DD/MM/YYYY)
*/

set linesize 300
set pages 50000

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

set verify off
column target format a64
column target_type format a25
column nbr_blocks format 9G999G999G999
column start_time_str format a30
column end_time_str format a30
column status format a15
column duration format a15
column estimated_cost format 999G999


select
  opid,
  target,
  target_type,
  target_size nbr_blocks,
  to_char(start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') start_time_str,
  to_char(end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') end_time_str,
  cast ((end_time - start_time) as interval day(2) to second(0)) duration,
  status,
  estimated_cost,
  priority
from
  dba_optstat_operation_tasks
where
  status in ('FAILED', 'TIMED OUT', 'SKIPPED')
  and start_time >= to_date(nvl('&1','01/01/1970'), 'DD/MM/YYYY')
order by 
  start_time, end_time
;

undef 1
