set lines 150
select owner, table_name, status, last_analyzed, num_rows, blocks, degree
from dba_tables
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
/
