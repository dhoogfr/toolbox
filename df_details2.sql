column curr_mb format 9G999G990D99
column max_mb format 9G9999990D99
column incr_mb format 9G999G990D99
column file_name format a70
--column file_name format a60
column tablespace_name format a20
break on tablespace_name skip 1
set linesize 150
set pagesize 999

select A.tablespace_name, file_name, bytes/1024/1024 curr_mb, autoextensible, 
       maxbytes/1024/1024 max_mb, (increment_by * block_size)/1024/1024 incr_mb
from ( select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_data_files
       union all
       select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_temp_files
     ) A, dba_tablespaces B
where A.tablespace_name = B.tablespace_name
order by A.tablespace_name, file_name;

clear breaks;
