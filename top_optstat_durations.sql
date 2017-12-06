/* list the top 10 cbo stats gathering durations
*/

set linesize 300
set pages 50000

column target format a64
column target_type format a25
column nbr_blocks format 9G999G999G999
column start_time_str format a30
column end_time_str format a30
column status format a15
column duration format a15
column estimated_cost format 999G999
column notes_xml format a220


with stat_tasks
as
( select
    target,
    target_type,
    target_size nbr_blocks,
    to_char(start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') start_time_str,
    to_char(end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') end_time_str,
    cast ((end_time - start_time) as interval day(2) to second(0)) duration,
    status,
    estimated_cost
  from
    dba_optstat_operation_tasks
)
select
  *
from
  ( select
      *
    from
      stat_tasks
    order by
      duration desc
  )
where
  rownum <= 10
;
