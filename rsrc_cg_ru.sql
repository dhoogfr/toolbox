set linesize 200
set pages 99999

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
col current_pqs_queued      format 9G999        heading "PQ Curr|queued"
col pq_active_time_sec      format 999G999G999  heading "PQ|Active sec"
col pq_queued_time_sec      format 999G999G999  heading "PQ|Queued sec"
col pq_queue_time_outs      format 999G999      heading "PQ|Timeouts"

compute sum of consumed_cpu_time_sec on report
compute sum of cpu_pct_used on report
compute sum of cpu_wait_time_sec on report
compute sum of pqs_completed on report
compute sum of pq_servers_used on report
compute sum of pqs_queued on report
compute sum of pq_active_time_sec on report
compute sum of pq_queued_time_sec on report
compute sum of pq_queue_time_outs on report

break on report

select
  decode (name, '_ORACLE_BACKGROUND_GROUP_', 'BACKGROUND', name) name,
  active_sessions, 
  execution_waiters, 
  requests, 
  (consumed_cpu_time/1000) consumed_cpu_time_sec, 
  cpu_waits, 
  (cpu_wait_time/1000) cpu_wait_time_sec, 
  (ratio_to_report(consumed_cpu_time) over () * 100) cpu_pct_used,
  yields,
  pqs_completed, 
  pq_servers_used, 
  pqs_queued, 
  current_pqs_queued,
  pq_active_time/1000 pq_active_time_sec, 
  pq_queued_time/1000 pq_queued_time_sec, 
  pq_queue_time_outs
from
  ( select
      name,
      sum(active_sessions)     active_sessions, 
      sum(execution_waiters)   execution_waiters, 
      sum(requests)            requests, 
      sum(consumed_cpu_time)   consumed_cpu_time, 
      sum(cpu_waits)           cpu_waits, 
      sum(cpu_wait_time)       cpu_wait_time, 
      sum(yields)              yields,
      sum(pqs_completed)       pqs_completed, 
      sum(pq_servers_used)     pq_servers_used, 
      sum(pqs_queued)          pqs_queued, 
      sum(current_pqs_queued)  current_pqs_queued,
      sum(pq_active_time)      pq_active_time, 
      sum(pq_queued_time)      pq_queued_time, 
      sum(pq_queue_time_outs)  pq_queue_time_outs
    from
      gv$rsrc_consumer_group
    group by
      name
  )
order by
  name
;

clear breaks
clear computes
