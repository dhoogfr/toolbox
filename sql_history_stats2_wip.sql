set linesize 200
set pages 50000
set verify off

column snap_id                  format 99999999             heading "snap id"
column begin_time               format a12                  heading "begin time"
column end_time                 format a12                  heading "end time"
column sql_id                   format a15                  heading "sql id"
column executions_delta         format 999G999G999          heading "executions|delta"
column elapsed_time_delta       format 999G999G999G999      heading "elapsed time|delta (µs)"
column disk_reads_delta         format 999G999G999          heading "disk reads|delta"
column buffer_gets_delta        format 999G999G999          heading "buffer gets|delta"
column iowait_delta             format 999G999G999G999      heading "io wait|delta (µs)"
column clwait_delta             format 999G999G999G999      heading "cluster wait|delta (µs)"

prompt Enter the begindate in the format DD/MM/YYYY HH24:MI
accept start_time prompt 'begin date: '

prompt Enter the enddate in the format DD/MM/YYYY HH24:MI
accept end_time prompt 'end date: '

prompt Enter the name of the program
accept program prompt "program: "


break on snap_id skip 1 on begin_time on end_time

compute sum of elapsed_time_delta on snap_id

with 
stat as
  ( select
      snap_id,
      sql_id,
      executions_delta,
      elapsed_time_delta,
      disk_reads_delta,
      buffer_gets_delta,
      iowait_delta,
      clwait_delta
    from
      dba_hist_sqlstat
    where
      sql_id in
        ( select
            sql_id
          from
            v$active_session_history   ash
          where
            ash.program = '&program'
            and ash.sample_time between
              to_date('&start_time', 'DD/MM/YYYY HH24:MI')
              and to_date('&end_time', 'DD/MM/YYYY HH24:MI')
        )
  )
select
  snap.snap_id,
  to_char(snap.begin_interval_time, 'DD/MM HH24:MI')  begin_time,
  to_char(snap.end_interval_time, 'DD/MM HH24:MI')   end_time,
  stat.sql_id,
  stat.executions_delta,
  stat.elapsed_time_delta,
  stat.disk_reads_delta,
  stat.buffer_gets_delta,
  stat.iowait_delta,
  stat.clwait_delta
from
  dba_hist_snapshot    snap, 
  stat
where
  snap.snap_id = stat.snap_id(+)
  and snap.begin_interval_time between
    to_date('&start_time', 'DD/MM/YYYY HH24:MI')
    and to_date('&end_time', 'DD/MM/YYYY HH24:MI')
order by
  snap.snap_id,
  stat.sql_id
;

clear breaks
clear computes

undefine start_time
undefine end_time
undefine program
