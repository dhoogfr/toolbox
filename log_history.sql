set linesize 140
set pages 999

column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

select to_char(day, 'DD/MM/YYYY') day, to_char(day,'DAY') dayname, day_arch#, graph
from ( select trunc(first_time) day, count(*) day_arch#,
              rpad('*',floor(count(*)/10),'*') graph
       from v$log_history
       where first_time >= trunc(sysdate) - 20
       group by trunc(first_time)
       order by day
     );