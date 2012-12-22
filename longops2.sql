set linesize 150
set pages 9999

column sid format 9999999
column RT format a10
column ET format a10
column opname format a30
column target format a20
column pct_complete format 09D00

select
  sid, serial#, sql_id, to_char(start_time, 'DD/MM/YYYY HH24:MI:SS') start_time, opname,
  round((100 * sofar)/totalwork, 2)  pct_complete,
  ( extract(day from (systimestamp + elapsed_seconds/24/60/60 - systimestamp)) || ' ' ||
    extract(hour from (systimestamp + elapsed_seconds/24/60/60 - systimestamp)) || ':' ||
    extract(minute from (systimestamp + elapsed_seconds/24/60/60 - systimestamp))  || ':' ||
    round(extract(second from (systimestamp + elapsed_seconds/24/60/60 - systimestamp)))  
  ) ET,
  ( extract(day from (systimestamp + time_remaining/24/60/60 - systimestamp))  || ' ' ||
    extract(hour from (systimestamp + time_remaining/24/60/60 - systimestamp))  || ':' ||
    extract(minute from (systimestamp + time_remaining/24/60/60 - systimestamp))  || ':' ||
    round(extract(second from (systimestamp + time_remaining/24/60/60 - systimestamp))) 
  ) RT
from
  v$session_longops
where
  time_remaining > 0;

