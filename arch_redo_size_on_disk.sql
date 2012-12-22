set pagesize 9999
set linesize 120
set verify off

column mb_arch format 9G999G999D99
column real_mb_in_period format 9G999G999D99
column max_mb_in_period format 9G999G999D99
column min_mb_in_period format 9G999G999D99
column counted format 99G999D99
column counted_in_period format 99G999D99

prompt Enter the nbr of days the archived redo logs should be kept on disk
accept days_on_disk prompt '# Days: '

select dag, mb_arch, 
       sum(mb_arch) over
           ( order by dag
             range &days_on_disk preceding
           ) as real_mb_in_period,
       counted,
       sum(counted) over
           ( order by dag
             range &days_on_disk preceding
           ) counted_in_period,
       max(mb_arch) over
           ( order by dag
             range &days_on_disk preceding
           ) * &days_on_disk as max_mb_in_period,
       min(mb_arch) over
           ( order by dag
             range &days_on_disk preceding
           ) * &days_on_disk as min_mb_in_period
from ( select trunc(completion_time) dag, sum(blocks * block_size)/1024/1024 mb_arch,
              count(*) counted
       from v$archived_log
       where months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );
 