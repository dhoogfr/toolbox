column db_block_size new_value _BLOCK_SIZE;

select to_number(value) db_block_size from v$parameter where name = 'db_block_size';

select
   a.tablespace_name,
   a.file_id,
   a.file_name,
   a.bytes/1024/1024 file_mb,
   ((c.block_id+(c.blocks-1)) * &_BLOCK_SIZE) /1024/1024 HWM_MB,
   (a.bytes - ((c.block_id+(c.blocks-1)) * &_BLOCK_SIZE))/1024/1024 SAVING_mb
from dba_data_files a,
   (select file_id,max(block_id) maximum
    from dba_extents
    group by file_id) b,
dba_extents c
where a.file_id = b.file_id
and c.file_id = b.file_id
and c.block_id = b.maximum
order by 6;