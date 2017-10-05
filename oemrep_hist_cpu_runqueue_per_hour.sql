/* historic hourly cpu run queue (per logical cpu) statistics
*/

column host_name format a30 heading "Host Name"
column virtual format a7 heading "Virtual|Guest"
column cpu_sockets format 999 heading "Num CPU|Sockets"
column cpu_cores format 999 heading "Num CPU|Cores"
column logical_cpus format 999 heading "Num CPU|Threads"
column rollup_timestamp_s format a16 heading "Date"
column cpuload_1min format 990D00 heading 'CPU Run Queue 1 min|per thread' 
column cpuload_5min format 990D00 heading 'CPU Run Queue 5 min|per thread' 
column cpuload_15min format 990D00 heading 'CPU Run Queue 15 min|per thread' 

break on host_name dup skip page

with 
cpu_runqueue as
( select
    hws.host_name, 
--    hws.cpu_count,
    hws.virtual,
    hws.physical_cpu_count,
    hws.total_cpu_cores,
    hws.logical_cpu_count,
    met.rollup_timestamp,
  --  tgt.target_guid,
  --  tgt.target_name,
    met.metric_column,
    met.maximum
  from
    mgmt$target tgt
      join mgmt$os_hw_summary   hws
        on ( hws.host_name = tgt.host_name )
      join mgmt$metric_hourly met
        on ( tgt.target_guid = met.target_guid)
  where
    tgt.target_type = 'host' 
    and met.metric_name = 'Load'
    and met.metric_column in ('cpuLoad', 'cpuLoad_1min', 'cpuLoad_15min')
    and tgt.host_name in ('sdtcsynx4adb01.localwan.net', 'sdtcsynx4adb02.localwan.net')
),
cpu_runqueue_p as
( select
    *
  from
    cpu_runqueue
  pivot
    ( sum(maximum)
      for metric_column in 
        ( 'cpuLoad' as CPULOAD, 
          'cpuLoad_1min' as CPULOAD_1MIN, 
          'cpuLoad_15min' as CPULOAD_15MIN
        )
    )
)
select
  host_name,
  virtual,
  physical_cpu_count  cpu_sockets,
  total_cpu_cores     cpu_cores,
  logical_cpu_count   logical_cpus,
  to_char(rollup_timestamp, 'DD/MM/YYYY HH24:MI') rollup_timestamp_s,
  cpuload_1min,
  cpuload cpuload_5min,
  cpuload_15min
from
  cpu_runqueue_p
order by
  host_name,
  rollup_timestamp
;

clear breaks
