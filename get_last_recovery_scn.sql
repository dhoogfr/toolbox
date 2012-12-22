set linesize 150
set pages 999
column name format a50
                           
select thread#, sequence#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') ntime, next_change#, status, name
from v$archived_log
where (thread#, next_change#) in 
        ( select thread#, max(next_change#) 
          from v$archived_log
          where archived = 'YES'
                and status = 'A'
                and resetlogs_id =
                    ( select resetlogs_id
                      from v$database_incarnation
                      where status = 'CURRENT'
                    )
          group by thread#
        )
      and status = 'A'
      and resetlogs_id =
        ( select resetlogs_id
          from v$database_incarnation
          where status = 'CURRENT'
        )
order by next_change# asc;
