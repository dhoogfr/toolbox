set pagesize 999
set linesize 200
set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column name format a25 heading "tablespace name"
column space_mb format 9G999g999g990D99 heading "curr df mbytes"
column maxspace_mb format 9G999g999g990D99 heading "max df mbytes"
column used format 9G999g999g990D99 heading "used mbytes"
column df_free format 9G999g999g990D99 heading "curr df free mbytes"
column maxdf_free format 9G999g999g990D99 heading "max df free mbytes"
column pct_free format 990D99 heading "% free"
column pct_maxfile_free format 990D99 heading "% maxfile free"

break on report

compute sum of space_mb on report
compute sum of maxspace_mb on report
compute sum of df_free on report
compute sum of maxdf_free on report
compute sum of used on report


select df.tablespace_name name, df.space space_mb, df.maxspace maxspace_mb, (df.space - nvl(fs.freespace,0)) used,
       nvl(fs.freespace,0) df_free, (nvl(fs.freespace,0) + df.maxspace - df.space) maxdf_free,
       100 * (nvl(fs.freespace,0) / df.space) pct_free,
       100 * ((nvl(fs.freespace,0) + df.maxspace - df.space) / df.maxspace) pct_maxfile_free
from ( select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_temp_files
       group by tablespace_name
     ) df,
     ( select tablespace_name, sum(bytes)/1024/1024 freespace
       from dba_free_space
       group by tablespace_name
     ) fs
where df.tablespace_name = fs.tablespace_name(+)
      and df.tablespace_name like nvl('&1', '%')
order by name;

clear breaks
clear computes

undef 1
