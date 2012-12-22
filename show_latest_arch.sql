select thread#, sequence#, next_change#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') next_time
from ( select thread#, sequence#, next_time, next_change#, 
              row_number() over
                ( partition by thread#
                  order by sequence# desc
                ) rn
       from v$archived_log
       where resetlogs_id = 
               ( select resetlogs_id 
                 from v$database_incarnation 
                 where status = 'CURRENT'
               )
     )
where rn = 1
order by thread#;
