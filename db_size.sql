column dummy noprint

column  pct_used format 999D9       heading "%|Used" 

column  name    format a25      heading "Tablespace Name" 

column  bytes   format 9G999G999G999G999    heading "Total Megs"  

column  used    format 99G999G999G999   heading "Used" 

column  free    format 999G999G999G999  heading "Free" 

break   on report 

compute sum of bytes on report 

compute sum of free on report 

compute sum of used on report 



select a.tablespace_name name, b.tablespace_name dummy,
       sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id ) /1024/1024 bytes,
       sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )/1024/1024  - sum(a.bytes)/count( distinct b.file_id )/1024/1024 used,
       sum(a.bytes)/count( distinct b.file_id ) /1024/1024 free,
       100 * ( (sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )) - (sum(a.bytes)/count( distinct b.file_id ) )) / (sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )) pct_used
from sys.dba_free_space a, sys.dba_data_files b
where a.tablespace_name = b.tablespace_name
group by a.tablespace_name, b.tablespace_name;
