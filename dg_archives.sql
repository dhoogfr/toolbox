select thread#, sequence#, to_char(first_time, 'DD/MM/YYYY HH24:MI') ft, archived, applied, fal
from v$archived_log
where first_time >= trunc(sysdate) -1
      and standby_dest = 'YES'
order by thread#, sequence#;


select thread#, sequence#, to_char(first_time, 'DD/MM/YYYY HH24:MI') ft, archived, applied, fal
from v$archived_log
where first_time >= trunc(sysdate) -1
order by thread#, sequence#;

