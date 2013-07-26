set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6


set linesize 250
set pagesize 9999
column max_mb format 999G999G990D99
column curr_mb format 999G999G990D99
column free_mb format 999G999G990D99
column pct_free format 900D99 heading "%FREE"
column NE format 9G999G999D99
column SSM format a6
column AT format a8
column tablespace_name format a30
column EM format a10
column contents format a15
column block_size format 99999 heading BSIZE

select A.tablespace_name, A.bigfile, A.plugged_in, A.status, block_size, A.contents, extent_management EM, allocation_type AT,
       segment_space_management ssm, decode(allocation_type, 'UNIFORM',next_extent/1024,'') NE,
       B.max_mb, B.curr_mb,
       (B.max_mb - B.curr_mb) + nvl(c.free_mb,0) free_mb, 
       ((100/B.max_mb)*(B.max_mb - B.curr_mb + nvl(c.free_mb,0))) pct_free
from dba_tablespaces A,
     ( select tablespace_name, sum(bytes)/1024/1024 curr_mb, 
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 curr_mb,
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_temp_files
       group by tablespace_name
     ) B,
     ( select tablespace_name, sum(bytes)/1024/1024 free_mb
       from dba_free_space
       group by tablespace_name
     ) C
where A.tablespace_name = B.tablespace_name
      and A.tablespace_name = C.tablespace_name(+)
      and A.tablespace_name like nvl('&1', '%')
order by tablespace_name;

undef 1
