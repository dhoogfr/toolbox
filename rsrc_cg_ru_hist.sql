set linesize 250
set pages 50000

col sequence#                format 999          heading "Seq"
col plan_name                format a25          heading "Plan Name"
col start_time               format a22          heading "Start Time"
col end_time                 format a22          heading "End Time"
col enabled_by_scheduler     format a10          heading "Enabled by|scheduler"
col consumer_group           format a25          heading "Consumer Group Name"
col cpu_wait_time_sec        format 999G999G999  heading "Waited|CPU Sec"
col cpu_waits                format 99G999G999   heading "CPU|Waits"
col consumed_cpu_time_sec    format 99G999G999   heading "Consumed|CPU Sec"
col yields                   format 9G999G999    heading "Yields"
col cpu_pct_used             format 999D99       heading "CPU %|Used "
col pqs_completed            format 999G999      heading "Completed|PQ Stat"
col pq_servers_used          format 999G999G999  heading "Tot Servers|used"
col pqs_queued               format 9G999        heading "PQ|queued"
col pq_active_time_sec       format 999G999G999  heading "PQ|Active sec"
col pq_queued_time_sec       format 999G999G999  heading "PQ|Queued sec"
col pq_queue_time_outs       format 999G999      heading "PQ|Timeouts"
col active_sess_limit_hits   format 999G999      heading "A Sess|Limits"

compute sum of consumed_cpu_time_sec on start_time
compute sum of cpu_pct_used on start_time
compute sum of cpu_wait_time_sec on start_time
compute sum of pqs_completed on start_time
compute sum of pq_servers_used on start_time
compute sum of pqs_queued on start_time
compute sum of pq_active_time_sec on start_time
compute sum of pq_queued_time_sec on start_time
compute sum of pq_queue_time_outs on start_time

break on start_time skip page on plan_name on enabled_by_scheduler on window_name

select
  to_char(start_time, 'DD/MM/YYYY HH24:MI:SS') start_time,
  plan_name,
  decode (consumer_group, '_ORACLE_BACKGROUND_GROUP_', 'BACKGROUND', consumer_group) consumer_group,
  consumed_cpu_time_sec, cpu_waits, cpu_wait_time_sec,
  (ratio_to_report(consumed_cpu_time_sec) over (partition by start_time) * 100) cpu_pct_used,
  yields, pqs_completed, pq_servers_used, pqs_queued, pq_active_time_sec, pq_queued_time_sec, 
  pq_queue_time_outs,active_sess_limit_hits
from
  ( select
      ph.start_time, 
      ph.name                           plan_name,
      cgh.name                          consumer_group,
      sum(cgh.consumed_cpu_time)/1000   consumed_cpu_time_sec,
      sum(cgh.cpu_waits)                cpu_waits,
      sum(cgh.cpu_wait_time)/1000       cpu_wait_time_sec,
      sum(cgh.yields)                   yields,
      sum(cgh.pqs_completed)            pqs_completed, 
      sum(cgh.pq_servers_used)          pq_servers_used, 
      sum(cgh.pqs_queued)               pqs_queued, 
      sum(cgh.pq_active_time)/1000      pq_active_time_sec, 
      sum(cgh.pq_queued_time)/1000      pq_queued_time_sec, 
      sum(cgh.pq_queue_time_outs)       pq_queue_time_outs,
      sum(cgh.active_sess_limit_hit)    active_sess_limit_hits
    from
      gv$rsrc_cons_group_history     cgh,
      gv$rsrc_plan_history           ph
    where
      cgh.inst_id = ph.inst_id
      and cgh.sequence# = ph.sequence#
    group by
      ph.start_time,
      ph.name,
      cgh.name
  ) a
order by
  a.start_time,
  plan_name,
  consumer_group
;

clear breaks
clear computes
