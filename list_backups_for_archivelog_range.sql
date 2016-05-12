select last_handle
from ( select br.thread#, br.sequence#, bp.handle,
              last_value(bp.handle) over
                ( partition by br.thread#, br.sequence#
                  order by bp.start_time
                  rows between unbounded preceding and unbounded following
                ) last_handle
       from rc_backup_redolog br,
            rc_backup_piece bp
       where br.db_key = bp.db_key
             and br.bs_key = bp.bs_key
             and br.db_name = 'QDOC'
             and br.sequence# between 2671 and 2850
             and br.thread# = 1
     )
group by last_handle
order by last_handle
