set linesize 120
set pagesize 999
break on dest_id skip 2 on thread# skip 1;

select dest_id, thread#, sequence#, next_change#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') next_time,
       to_char(completion_time,'DD/MM/YYYY HH24:MI:SS') completion_time, archived, applied, deleted, status, fal
from v$archived_log
where standby_dest='YES'
      and completion_time >= trunc(sysdate) -1
order by dest_id, thread#, sequence#;

clear breaks
