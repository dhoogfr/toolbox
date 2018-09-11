select instance_name from v$instance;

select to_char(min(dag), 'DD/MM/YYYY HH24:MI:SS') start_day, to_char(max(dag) + 1 - 1/(24*60*60), 'DD/MM/YYYY HH24:MI:SS') end_day,
       (max(dag) - min(dag) + 1) days_between,
       to_char(avg(gen_archived_size),'9G999G999D99') avg_archived_per_day
from ( select trunc(completion_time) dag, sum(blocks * block_size)/1024/1024 gen_archived_size
       from v$archived_log
       where months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );

exit