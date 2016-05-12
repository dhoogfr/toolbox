column tbs_mb format 9G999G999D99
column tbs_max_mb format 9G999G999D99
column tbs_used_mb format 9G999G999D99
break on name skip 1

select name, rtime, tablespace_size * tbs.block_size/1024/1024 tbs_mb, tablespace_maxsize * tbs.block_size/1024/1024 tbs_max_mb,
       tablespace_usedsize * tbs.block_size/1024/1024 tbs_used_mb
from dba_hist_tbspc_space_usage tbssp, v$tablespace ts, dba_tablespaces tbs
where tbssp.tablespace_id = ts.ts#
      and ts.name = tbs.tablespace_name
      and tbs.tablespace_name = '&tablespace_name'
order by name, snap_id;
