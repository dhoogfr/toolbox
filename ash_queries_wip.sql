set linesize 200
set pages 50000

column tm_delta_time      format 99G999G999G999     heading "tm time|delta (µs)"
column tm_delta_db_time   format 99G999G999G999     heading "tm db|delta (µs)"
column tm_delta_cpu_time  format 99G999G999G999     heading "tm cpu|delta (µs)"
column time_waited        format 99G999G999G999     heading "waited|(µs)"
column delta_time         format 99G999G999G999     heading "delta time|(µs)"
column first_time         format a15                heading "first sample"
column last_time         format a15                heading "last sample"

select
  sum(ash.tm_delta_time) tm_delta_time,
  sum(ash.tm_delta_db_time) tm_delta_db_time,
  sum(ash.tm_delta_cpu_time) tm_delta_cpu_time,
  sum(ash.time_waited) time_waited, 
  sum(ash.delta_time) delta_time,
  to_char(min(ash.sample_time), 'DD/MM HH24:MI:SS') first_time,
  to_char(max(ash.sample_time), 'DD/MM HH24:MI:SS') last_time
from
  gv$active_session_history   ash
where
  ash.program = 'batch.exe'
  and ash.sample_time between 
    to_date('22/11/2012 10:38', 'DD/MM/YYYY HH24:MI')
    and to_date('22/11/2012 18:20', 'DD/MM/YYYY HH24:MI')
;



set linesize 200
set pages 50000

column sql_id             format a15                heading "sql id"
column tm_delta_time      format 99G999G999G999     heading "tm time|delta (µs)"
column tm_delta_db_time   format 99G999G999G999     heading "tm db|delta (µs)"
column tm_delta_cpu_time  format 99G999G999G999     heading "tm cpu|delta (µs)"
column time_waited        format 99G999G999G999     heading "waited|(µs)"
column delta_time         format 99G999G999G999     heading "delta time|(µs)"

select
  sql_id,
  sum(ash.tm_delta_time) tm_delta_time,
  sum(ash.tm_delta_db_time) tm_delta_db_time,
  sum(ash.tm_delta_cpu_time) tm_delta_cpu_time,
  sum(ash.time_waited) time_waited, 
  sum(ash.delta_time) delta_time
from
  gv$active_session_history   ash
where
  ash.program = 'batch.exe'
  and ash.sample_time between 
    to_date('22/11/2012 18:20', 'DD/MM/YYYY HH24:MI')
    and to_date('23/11/2012 02:16', 'DD/MM/YYYY HH24:MI')
group by
  sql_id
order by
  tm_delta_db_time desc
;



set linesize 200
set pages 50000

column sample_id          format 99999999           heading "sample"
column sample_time        format a30                heading "sample time"
column session_id         format 9999999            heading "session"
column session_serial#    format 9999999            heading "serial#"
column sql_id             format a15                heading "sql id"
column tm_delta_time      format 99G999G999G999     heading "tm time|delta (µs)"
column tm_delta_db_time   format 99G999G999G999     heading "tm db|delta (µs)"
column tm_delta_cpu_time  format 99G999G999G999     heading "tm cpu|delta (µs)"
column time_waited        format 99G999G999G999     heading "waited|(µs)"
column delta_time         format 99G999G999G999     heading "delta time|(µs)"

select
  ash.sample_id,
  ash.sample_time,
  ash.session_id,
  ash.session_serial#,
  ash.sql_id,
  ash.tm_delta_time,
  ash.tm_delta_db_time,
  ash.tm_delta_cpu_time,
  ash.time_waited,
  ash.delta_time
from
  gv$active_session_history   ash
where
  ash.program = 'batch.exe'
  and ash.sample_time > to_date('21/11/2012 22:00', 'DD/MM/YYYY HH24:MI')
  and ash.sql_id = 'c6v8hz7wg8mym'
order by
  ash.sample_id,
  ash.session_id,
  ash.session_serial#
;



