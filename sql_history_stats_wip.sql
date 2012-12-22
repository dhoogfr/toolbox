set linesize 200
set pages 50000

column instance_number          format 99                   heading "inst"
column snap_id                  format 99999999             heading "snap id"
column begin_time               format a12                  heading "begin time"
column end_time                 format a12                  heading "end time"
column executions_delta         format 999G999G999          heading "executions|delta"
column elapsed_time_delta       format 999G999G999G999      heading "elapsed time|delta (µs)"
column disk_reads_delta         format 999G999G999          heading "disk reads|delta"
column buffer_gets_delta        format 999G999G999          heading "buffer gets|delta"
column iowait_delta             format 999G999G999G999      heading "io wait|delta (µs)"
column clwait_delta             format 999G999G999G999      heading "cluster wait|delta (µs)"

break on instance_number skip 1


select
  snap.instance_number, 
  snap.snap_id,
  to_char(snap.begin_interval_time, 'DD/MM HH24:MI')  begin_time,
  to_char(snap.end_interval_time, 'DD/MM HH24:MI')   end_time,
  stat.executions_delta,
  stat.elapsed_time_delta,
  stat.disk_reads_delta,
  stat.buffer_gets_delta,
  stat.iowait_delta,
  stat.clwait_delta
from
  dba_hist_snapshot    snap, 
  dba_hist_sqlstat     stat
where
  snap.snap_id = stat.snap_id(+)
  and snap.instance_number = stat.instance_number(+)
  and stat.sql_id(+) = '&sql_id'
  and snap.begin_interval_time between
    to_date('&begin_time', 'DD/MM/YYYY HH24:MI')
    and to_date('&end_time', 'DD/MM/YYYY HH24:MI')
order by
  snap.instance_number,
  snap.snap_id
;

clear breaks;
