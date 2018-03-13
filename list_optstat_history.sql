/* list the history of the optimizer statistic operations
   optionally filters on the start time in the format DD/MM/YYYY and the target name (which supports wildcards)
*/

set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
column inputpar02 new_value 2 noprint
select 2 inputpar02 from dual where 1=2;
set feedback 6


column operation format a40
column target format a64
column start_time_str format a30
column end_time_str format a30
column status format a15
column duration format a15
column nbr_tasks format 9G999G999

with task_counts
as 
( select
    opid,
    count(*) nbr_tasks
  from
    dba_optstat_operation_tasks
  group by
    opid
)
select
  op.id,
  op.operation,
  op.target, 
  to_char(op.start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') start_time_str,
  to_char(op.end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') end_time_str,
  cast ((op.end_time - op.start_time) as interval day(2) to second(0)) duration,
  op.status,
  tc.nbr_tasks 
from
  dba_optstat_operations op
    left outer join task_counts tc
      on ( op.id = tc.opid
         )
where
  start_time >= to_date(nvl('&1','01/01/1970'), 'DD/MM/YYYY')
  and nvl(target, ' ') like nvl('&2', '%')
order by
  id
;

undef 1
undef 2