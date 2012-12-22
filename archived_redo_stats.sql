set echo off
set pagesize 999
set linesize 150

/* 
Average redo generation
*/

column start_day format a22
column end_day format a22
column days_between format 99
column avg_archived_per_day format a13 heading avg_gen

select to_char(min(dag), 'DD/MM/YYYY HH24:MI:SS') start_day, to_char(max(dag) + 1 - 1/(24*60*60), 'DD/MM/YYYY HH24:MI:SS') end_day,
       (max(dag) - min(dag) + 1) days_between,
       to_char(avg(gen_archived_size),'9G999G999D99') avg_archived_per_day
from ( select trunc(completion_time) dag, sum(blocks * block_size)/1024/1024 gen_archived_size
       from v$archived_log
       where standby_dest = 'NO'
             and months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );

/* 
archived redo over the (max) last 10 days
*/
column day_arch_size format 99G999D99
column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

select to_char(day, 'DD/MM/YYYY') day, to_char(day,'DAY') dayname, day_arch_size, day_arch#, graph
from ( select trunc(completion_time) day, sum(blocks * block_size)/1024/1024 day_arch_size, count(*) day_arch#,
              rpad('*',floor(count(*)/10),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 10
       group by trunc(completion_time)
       order by day
     );
     
/*
archived redo per hour over the (max) last 2 days
*/
column hour_arch_size format 99G999D99
column hour_arch# format 9G999
column graph format a15
column dayname format a12
column dayhour format a18
break on dayname skip 1

select to_char(dayhour,'DAY') dayname, to_char(dayhour, 'DD/MM/YYYY HH24:MI') dayhour, hour_arch_size, hour_arch#, graph
from ( select trunc(completion_time, 'HH') dayhour, sum(blocks * block_size)/1024/1024 hour_arch_size, count(*) hour_arch#,
              rpad('*',floor(count(*)/4),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 2
       group by trunc(completion_time, 'HH')
       order by dayhour
     );
     
clear breaks;
