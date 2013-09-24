-- list all datafiles with more than 50% free space (calculated against the current size, not the maxsize) and for which the free space is more than 10GB
-- and include the datafile high water mark in the output

set pagesize 999
set linesize 200
set verify off


column tablespace_name format a30 heading "tbs name"
column file_id format 9999 heading "file"
column df_curr_size_mb format 9G999G999G990D99 heading "curr df size (mb)"
column df_max_size_mb format 9G999G999G990D99 heading "max df size (mb)"
column df_used_size_mb format 9G999G999G990D99 heading "used df size (mb)"
column df_free_size_mb format 9G999g999g990D99 heading "df free (mb)"
column df_pct_free format 990D99 heading "df free (%)"
column df_hwm_block_id format 9999999999999 heading "hwm block id"
column df_hwm_mb format 9G999G999G990D99 heading "df hwm (mb)"
column df_headspace_mb format 9G999g999g990D99 heading "df headspace (mb)"


break on tablespace_name skip 1 on report

compute sum of df_curr_size_mb on tablespace_name 
compute sum of df_curr_size_mb on report
compute sum of df_max_size_mb on tablespace_name
compute sum of df_free_size_mb on tablespace_name
compute sum of df_free_size_mb on report
compute sum of df_used_size_mb on tablespace_name
compute sum of df_used_size_mb on report
compute sum of df_headspace_mb on tablespace_name
compute sum of df_headspace_mb on report

with
  df as
  ( select
      tablespace_name, 
      file_id, 
      bytes, 
      maxbytes
    from 
      dba_data_files
    union all
    select
      tablespace_name,
      file_id,
      bytes,
      maxbytes
    from
      dba_temp_files
  ),
  high_block as
  ( select
      file_id,
      max(block_id) m_block_id
    from
      dba_extents
    group by
      file_id
  ),
  hwm as
  ( select
      df.file_id,
      hb.m_block_id df_hwm_block_id,
      ((ext.block_id +(ext.blocks-1)) * tbs.block_size) df_hwm_bytes,
      (df.bytes - ((ext.block_id+(ext.blocks-1)) * tbs.block_size)) df_headspace_bytes
    from
      dba_extents     ext,
      high_block      hb,
      df,
      dba_tablespaces tbs
    where
      df.file_id = hb.file_id
      and ext.file_id = hb.file_id
      and ext.block_id = hb.m_block_id
      and tbs.tablespace_name = ext.tablespace_name
  ),
  df_usage as
  ( select
      df.tablespace_name,
      df.file_id,
      df.bytes df_curr_size,
      greatest(df.maxbytes,df.bytes) df_max_size,
      (df.bytes - nvl(fs.bytes,0)) df_used,
      nvl(fs.bytes,0) df_free,
      100 * (nvl(fs.bytes,0) / df.bytes) df_pct_free
    from
      df,  
      ( select
          tablespace_name,
          file_id,
          sum(bytes) bytes
        from
          dba_free_space
        group by
          tablespace_name,
          file_id
      ) fs
    where 
      df.tablespace_name = fs.tablespace_name(+)
  )
select 
  dfu.tablespace_name,
  dfu.file_id,
  (dfu.df_curr_size/1024/1024) df_curr_size_mb,
  (dfu.df_max_size/1024/1024) df_max_size_mb,
  (dfu.df_used/1024/1024) df_used_size_mb,
  (dfu.df_free/1024/1024) df_free_size_mb,
  dfu.df_pct_free,
  hwm.df_hwm_block_id,
  (hwm.df_hwm_bytes/1024/1024) df_hwm_mb,
  (hwm.df_headspace_bytes/1024/1024) df_headspace_mb
from 
  df_usage  dfu,
  hwm
where
  dfu.file_id = hwm.file_id
  and dfu.df_pct_free > 50
  and (dfu.df_curr_size - dfu.df_used) > 10 * 1024 * 1024 * 1024
order by
  df_headspace_bytes desc
;

clear breaks
clear computes
