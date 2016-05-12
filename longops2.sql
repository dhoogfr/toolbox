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
  ( extract(day from (systimestamp + numtodsinterval(elapsed_seconds, 'second') - systimestamp)) || ' ' ||
    extract(hour from (systimestamp + numtodsinterval(elapsed_seconds, 'second') - systimestamp)) || ':' ||
    extract(minute from (systimestamp + numtodsinterval(elapsed_seconds, 'second') - systimestamp))  || ':' ||
    round(extract(second from (systimestamp + numtodsinterval(elapsed_seconds, 'second') - systimestamp)))  
  ) ET,
  ( extract(day from (systimestamp + numtodsinterval(time_remaining, 'second') - systimestamp))  || ' ' ||
    extract(hour from (systimestamp + numtodsinterval(time_remaining, 'second') - systimestamp))  || ':' ||
    extract(minute from (systimestamp + numtodsinterval(time_remaining, 'second') - systimestamp))  || ':' ||
    round(extract(second from (systimestamp + numtodsinterval(time_remaining, 'second') - systimestamp))) 
  ) RT
from
  v$session_longops
where
  time_remaining > 0
;

