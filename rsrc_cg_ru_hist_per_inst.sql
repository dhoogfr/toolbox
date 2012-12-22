set linesize 200
set pages 50000

col inst_id                  format 999          heading "Inst"
--col sequence#                format 999          heading "Seq"
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

compute sum of consumed_cpu_time_sec on inst_id
compute sum of cpu_pct_used on inst_id
compute sum of cpu_wait_time_sec on inst_id
compute sum of pqs_completed on inst_id
compute sum of pq_servers_used on inst_id
compute sum of pqs_queued on inst_id
compute sum of pq_active_time_sec on inst_id
compute sum of pq_queued_time_sec on inst_id
compute sum of pq_queue_time_outs on inst_id

break on start_time skip page on inst_id skip 1 on plan_name on start_time on enabled_by_scheduler on window_name
      
select
  to_char(ph.start_time, 'DD/MM/YYYY HH24:MI:SS') start_time,
  ph.inst_id,
  ph.name plan_name,
--  to_char(ph.end_time, 'DD/MM/YYYY HH24:MI:SS') end_time,
  decode (cgh.name, '_ORACLE_BACKGROUND_GROUP_', 'BACKGROUND', cgh.name) consumer_group,
  cgh.consumed_cpu_time/1000 consumed_cpu_time_sec, 
  cgh.cpu_waits, 
  cgh.cpu_wait_time/1000 cpu_wait_time_sec,
  (ratio_to_report(cgh.consumed_cpu_time) over (partition by cgh.inst_id, cgh.sequence#) * 100) cpu_pct_used,
  cgh.yields, cgh.pqs_completed, cgh.pq_servers_used, cgh.pqs_queued, 
  cgh.pq_active_time/1000 pq_active_time_sec, 
  cgh.pq_queued_time/1000 pq_queued_time_sec, 
  cgh.pq_queue_time_outs
from
  gv$rsrc_cons_group_history     cgh,
  gv$rsrc_plan_history           ph
where
  cgh.inst_id = ph.inst_id
  and cgh.sequence# = ph.sequence#
order by
  ph.start_time,
  ph.inst_id,
  consumer_group
;

clear breaks
clear computes
