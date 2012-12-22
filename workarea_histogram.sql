set pages 999
set linesize 120

column losize format a15 
column hisize format a15
column optimal format 999G999G999
column onepass format 999G999G999
column multipasses format 999G999G999
column total format 9G999G999G999

select case when low_optimal_size < 1024 then
              to_char(low_optimal_size,'99G999D99')
            when low_optimal_size between 1024 and 1024*1024 -1
              then to_char(low_optimal_size/1024,'99G999D99') || ' K'
            when low_optimal_size between 1024*1024 and 1024*1024*1024 -1
              then to_char(low_optimal_size/1024/1024,'99G999D99') || ' M'
            when low_optimal_size >= 1024*1024*1024
              then to_char(low_optimal_size/1024/1024/1024,'99G999D99') || ' G'
       end losize,
       case when high_optimal_size < 1024 then
              to_char(high_optimal_size,'99G999D99')
            when high_optimal_size between 1024 and 1024*1024 - 1
              then to_char(high_optimal_size/1024,'99G999D99') || ' K'
            when high_optimal_size between 1024*1024 and 1024*1024*1024 -1
              then to_char(high_optimal_size/1024/1024,'99G999D99') || ' M'
            when high_optimal_size >= 1024*1024*1024
              then to_char(high_optimal_size/1024/1024/1024,'99G999D99') || ' G'
       end hisize, 
       optimal_executions optimal, onepass_executions onepass, multipasses_executions multipasses,
       total_executions total
from v$sql_workarea_histogram
order by low_optimal_size, high_optimal_size;
