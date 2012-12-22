select resetlogs_id, thread#, sequence#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') nexttime, name
from v$archived_log
where &scn between first_change# and next_change#
order by resetlogs_id, thread#, sequence#, name;