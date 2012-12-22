set linesize 200
set pages 99999

ttitle left "Instance ID:" instid skip 2

col inst_id                 new_value instid noprint

col name                    format a30          heading "Name"
col active_sessions         format 999          heading "Active|Sessions"
col execution_waiters       format 999          heading "Execution|Waiters"
col requests                format 9G999G999    heading "Requests"
col cpu_wait_time_sec       format 999G999G999  heading "Waited|CPU Sec"
col cpu_waits               format 99G999G999   heading "CPU|Waits"
col consumed_cpu_time_sec   format 99G999G999   heading "Consumed|CPU Sec"
col yields                  format 9G999G999    heading "Yields"
col cpu_pct_used            format 999D99       heading "CPU %|Used "
col pqs_completed           format 999G999      heading "Completed|PQ Stat"
col pq_servers_used         format 999G999G999  heading "Tot Servers|used"
col pqs_queued              format 9G999        heading "PQ|queued"
col pq_active_time_sec      format 999G999G999  heading "PQ|Active sec"
col pq_queued_time_sec      format 999G999G999  heading "PQ|Queued sec"
col pq_queue_time_outs      format 999G999      heading "PQ|Timeouts"

compute sum of consumed_cpu_time_sec on inst_id
compute sum of cpu_pct_used on inst_id
compute sum of cpu_wait_time_sec on inst_id
compute sum of pqs_completed on inst_id
compute sum of pq_servers_used on inst_id
compute sum of pqs_queued on inst_id
compute sum of pq_active_time_sec on inst_id
compute sum of pq_queued_time_sec on inst_id
compute sum of pq_queue_time_outs on inst_id

break on inst_id skip page

select
  inst_id,
  decode (name, '_ORACLE_BACKGROUND_GROUP_', 'BACKGROUND', name) name,
  active_sessions, execution_waiters, requests, 
  consumed_cpu_time/1000 consumed_cpu_time_sec, 
  cpu_waits, 
  cpu_wait_time/1000 cpu_wait_time_sec, 
  (ratio_to_report(consumed_cpu_time) over (partition by inst_id) * 100) cpu_pct_used,
  yields
  pqs_completed, 
  pq_servers_used, 
  pqs_queued, 
  pq_active_time/1000 pq_active_time_sec, 
  pq_queued_time/1000 pq_queued_time_sec, 
  pq_queue_time_outs
from
  gv$rsrc_consumer_group
order by
  inst_id,
  name
;

clear breaks
clear computes
ttitle off
column inst_id clear
