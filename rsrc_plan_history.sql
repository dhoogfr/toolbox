col start_time                   format a22      heading "Start Time"
col end_time                     format a22      heading "End Time"
col inst_id                      format 999      heading "Inst"
col name                         format a30      heading "Name"
col enabled_by_scheduler         format a10      heading "Enabled by|scheduler"
col window_name                  format a20      heading "Window"
col allowed_automated_switches   format a8       heading "Switches|allowed"
col cpu_managed                  format a7       heading "CPU|Managed"
col instance_caging              format a7       heading "Inst|Caging"
col parallel_execution_managed   format a10      heading "PXE|Managed"

break on start_time skip 1 on end_time

select
  to_char(start_time, 'DD/MM/YYYY HH24:MI:SS') start_time,
  to_char(end_time, 'DD/MM/YYYY HH24:MI:SS') end_time,
  inst_id,
  name,
  enabled_by_scheduler,
  window_name,
  allowed_automated_switches,
  cpu_managed,
  instance_caging,
  parallel_execution_managed
from
  gv$rsrc_plan_history ph
order by
  ph.start_time,
  inst_id
;

clear breaks
