set linesize 120
set pagesize 999

column max_mb format 9G999G999D99
column used_mb format 9G999G999D99
column curr_mb format 9G999G999D99
column pct_max_used format 999D99
column pct_curr_used format 999D99

select B.tablespace_name, max_mb, B.curr_mb, nvl(used_mb,0) used_mb, 
       nvl2(used_mb,((100/max_mb)*used_mb),0) pct_max_used, 
       nvl2(used_mb,((100/curr_mb)*used_mb),0) pct_curr_used
from ( select tablespace_name, sum(bytes)/1024/1024 used_mb
       from dba_segments
       group by tablespace_name
     ) A,
     ( select tablespace_name, sum(greatest(bytes, maxbytes))/1024/1024 max_mb, sum(bytes)/1024/1024 curr_mb
       from dba_data_files
       group by tablespace_name
     ) B
where A.tablespace_name(+) = B.tablespace_name
order by tablespace_name;
