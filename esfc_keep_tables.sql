select owner, table_name, status, last_analyzed, num_rows, blocks, degree, cell_flash_cache
from dba_tables
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
and cell_flash_cache like nvl('&cell_flash_cache','KEEP')
/
