select sql_text
from v$sqltext_with_newlines
where (address, hash_value)
        = ( select sql_address, sql_hash_value
            from v$session
            where sid = &sid
                  and serial# = '&serial'
          )
order by piece;