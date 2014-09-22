column next_change# format 999999999999999
select *
from ( select thread#, max(sequence#) sequence#, max(next_change#) next_change#, to_char(max(next_time), 'DD/MM/YYYY HH24:MI:SS') next_time
       from v$backup_archivelog_details
       where resetlogs_time =
              ( select resetlogs_time
                from v$database_incarnation
                where status = 'CURRENT'
              )
       group by thread#
       order by next_change#
     )
where rownum = 1;