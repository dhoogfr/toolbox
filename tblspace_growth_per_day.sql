column tbs_mb format 9G999G999D99
column tbs_max_mb format 9G999G999D99
column tbs_used_mb format 9G999G999D99
break on tablespace_name skip 1

with hist_per_day
as
( select /*+ MATERIALIZE */
         tablespace_id, day, first_snap
  from ( select tablespace_id, trunc(to_date(rtime, 'MM/DD/YYYY HH24:MI:SS')) day, 
                first_value(snap_id)
                  over ( partition by tablespace_id, trunc(to_date(rtime, 'MM/DD/YYYY HH24:MI:SS'))
                         order by to_date(rtime, 'MM/DD/YYYY HH24:MI:SS')
                       ) first_snap
         from dba_hist_tbspc_space_usage
       )
  group by tablespace_id, day, first_snap
)
select tbs.tablespace_name, hpd.day, tbssp.tablespace_size * tbs.block_size/1024/1024 tbs_mb,
       tbssp.tablespace_maxsize * tbs.block_size/1024/1024 tbs_max_mb,
       tbssp.tablespace_usedsize * tbs.block_size/1024/1024 tbs_used_mb
from hist_per_day hpd, dba_hist_tbspc_space_usage tbssp, v$tablespace ts, dba_tablespaces tbs
where hpd.first_snap = tbssp.snap_id
      and hpd.tablespace_id = tbssp.tablespace_id
      and tbssp.tablespace_id = ts.ts#
      and ts.name = tbs.tablespace_name
order by tbs.tablespace_name, snap_id;
