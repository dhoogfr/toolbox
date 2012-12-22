-- Monitor historical statistics for Parallel Statement Queuing. 
-- The following query lists the number of parallel statements run, the average run time, 
-- the number of parallel statements queued, and the average queue time by consumer group.

select
  name, 
  sum(pqs_completed) pqs_completed, 
  sum(decode(pqs_completed, 0, 0, pq_active_time / pqs_completed)) avg_pq_run_time, 
  sum(pqs_queued) pqs_queued, 
  sum(decode(pqs_queued, 0, 0, pq_queued_time / pqs_queued)) avg_pq_queue_time 
from
  gv$rsrc_consumer_group
group by name
; 
