select plan_table_output
from table( dbms_xplan.display 
                ( 'dynamic_plan_table',
                  ( select rawtohex(address) || '_' || child_number
                    from v$sql_plan, v$session
                    where address = sql_address
                          and hash_value = sql_hash_value
                          and sid = 8
                          and serial# = 822
                          and rownum = 1
                  ), 'serial'
                )
          );