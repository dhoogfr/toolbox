select sql_id, sql_fulltext
from v$sql
where sql_id
        = ( select sql_id
            from v$session, v$process
            where paddr = addr
                  and spid = '&processid'
          );