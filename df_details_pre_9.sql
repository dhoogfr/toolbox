select A.tablespace_name, file_name, bytes/1024/1024 curr_mb, autoextensible,
       maxbytes/1024/1024 max_mb, (increment_by * (select value from v$parameter where name='db_block_size'))/1024/1024 incr_mb
from ( select tablespace_name, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_data_files
       union all
       select tablespace_name, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_temp_files
     ) A, dba_tablespaces B
where A.tablespace_name = B.tablespace_name
order by A.tablespace_name, file_name
/
