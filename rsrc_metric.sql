select
  to_char(begin_time, 'DD/MM/YYYY HH24:MI:SS') begin_time,
  to_char(end_time, 'DD/MM/YYYY HH24:MI:SS') end_time,
  consumer_group_name, cpu_wait_time, num_cpus, cpu_utilization_limit,
  avg_cpu_utilization, avg_running_sessions, avg_waiting_sessions
from
  v$rsrcmgrmetric
order by
  consumer_group_name
;


select
  to_char(begin_time, 'DD/MM/YYYY HH24:MI:SS') begin_time,
  to_char(end_time, 'DD/MM/YYYY HH24:MI:SS') end_time,
  consumer_group_name, cpu_wait_time, num_cpus, cpu_utilization_limit,
  avg_cpu_utilization, avg_running_sessions, avg_waiting_sessions
from
  v$rsrcmgrmetric_history
order by
  begin_time,
  consumer_group_name
;
