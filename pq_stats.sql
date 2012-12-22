-- The following query lists the number of parallel statements that are currently running or queued per consumer group.  
-- It also lists the number of parallel servers currently used per consumer group.

select
  name, 
  sum(current_pqs_active) pqs_active, 
  sum(current_pq_servers_active) pq_servers_active, 
  sum(current_pqs_queued) pqs_queued 
from
  gv$rsrc_consumer_group
group by
  name
;
