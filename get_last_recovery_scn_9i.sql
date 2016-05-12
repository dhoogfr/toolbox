select thread#, sequence#, next_change#, to_char(next_time, 'DD/MM/YYYY HH24:MI:SS') ntime
from ( select thread#, sequence#, next_change#, next_time,
              row_number() over
           ( partition by thread#
                  order by sequence# desc
                ) rn
       from v$backup_redolog
     )
where rn = 1