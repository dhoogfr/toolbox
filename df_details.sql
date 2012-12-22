set linesize 120
set pages 999
set verify off

column file_name format a70
column mb format 9G999G999D99
column incr_by_mb format 9G999D99
column max_mb format 9G999G999D99

compute sum of MB on report
compute sum of max_MB on report

break on report
with
  files as
    ( select
        file_id, file_name, bytes, maxbytes, increment_by
      from
        dba_data_files
      where
        tablespace_name = '&&tablespacename'
      union all
      select
        file_id, file_name, bytes, maxbytes, increment_by
      from
        dba_temp_files
      where
        tablespace_name = '&&tablespacename'
    ),
  blocksize as
    ( select
        block_size
      from
        dba_tablespaces
      where
        tablespace_name = '&&tablespacename'
    )
select
  files.file_id, files.file_name, 
  (files.bytes/1024/1024) MB, 
  (files.maxbytes/1024/1024) max_MB,
  ((files.increment_by * blocksize.block_size )/1024/1024) incr_by_mb
from
  files,
  blocksize
order by
  file_id
/

clear breaks
undefine tablespacename