column hash_value format 99999999999
column piece format 999
column sql_text format a64
break on hash_value skip 1

select hash_value, piece, sql_text
from v$sqltext_with_newlines
where hash_value in
        ( select hash_value
          from v$sqltext_with_newlines
          where upper(sql_text) like '%KRUIDVAT_AUDITRECORD%'
        )
order by hash_value, piece;