/* top 10 targets based upon the cbo calculation duration
   
   The sql statement checks for the 10 ranked segments based upon their longest cbo stats collection duration
*/

set linesize 300
set pages 50000

column operation format a30
column target format a50
column target_type format a25
column nbr_blocks format 9G999G999G999
column start_time_str format a30
column end_time_str format a30
column status format a15
column duration format a15
column estimated_cost format 999G999
column target_notes_xml format a200
column ops_notes_xml format a200
column nbr_blocks format 9G999G999G999

-- rank the different collection duration per target
with
target_ranking
as
( select
    opid,
    target,
    target_type,
    target_size,
    start_time,
    end_time,
    cast ((end_time - start_time) as interval day(2) to second(0)) duration,
    status,
    estimated_cost,
    notes,
    dense_rank() over
      ( partition by target, target_type
        order by cast ((end_time - start_time) as interval day(2) to second(0)) desc
      ) trgt_rank
  from
    dba_optstat_operation_tasks
),
-- take the longest duration for each target and order these targets on duration, selecting the top 10 targets
filtered_targets
as
( select
    --+ MATERIALIZE
    *
  from
    ( select
        opid,
        target,
        target_type,
        target_size,
        start_time,
        end_time,
        duration,
        status,
        estimated_cost,
        notes
      from
        target_ranking
      where
        trgt_rank = 1
      order by
        duration desc
    )
  where
    rownum <= 10
)
-- join the filtered targets with the parent operation
select
  tgt.opid,
  ops.operation,
  tgt.target,
  tgt.target_type,
  tgt.target_size nbr_blocks,
  to_char(tgt.start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') start_time_str,
  to_char(tgt.end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') end_time_str,
  tgt.duration,
  tgt.status,
--  tgt.estimated_cost,
  xmlserialize(content xmltype(nvl2(tgt.notes, tgt.notes, '<notes/>')) as clob indent size = 2) target_notes_xml,
  xmlserialize(content xmltype(nvl2(ops.notes, ops.notes, '<notes/>')) as clob indent size = 2) ops_notes_xml
from
  filtered_targets                  tgt
    join dba_optstat_operations     ops
      on ( tgt.opid = ops.id)
order by
  duration desc
;
