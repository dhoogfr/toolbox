set pages 999
set linesize 200

column nbr_exec format 99G999G999
column ela_sec format 999G999G999
column dreads format 999G999G999
column bgets format 999G999G999
column avg_ela_sec format 9G999G999D99
column avg_dreads format 99G999G999
column avg_bgets format 999G999G999

with exec_stats as
  ( select
      instance_number,
      sqlstat.sql_id,
      sqlstat.plan_hash_value phash_value,
      min(sqlstat.snap_id) min_snap_id,
      max(sqlstat.snap_id) max_snap_id,
      sum(sqlstat.executions_delta) nbr_exec,
      sum(sqlstat.elapsed_time_delta)/1000000 ela_sec,
      sum(sqlstat.disk_reads_delta) dreads,
      sum(sqlstat.buffer_gets_delta) bgets
    from
      dba_hist_sqlstat sqlstat
    where
      sql_id = '&sql_id'
    group by
      instance_number,
      sql_id,
      plan_hash_value 
  )
select
  exec_stats.instance_number,
  to_char(snap1.begin_interval_time, 'DD/MM/YYYY HH24:MI') earliest_occur,
  to_char(snap2.end_interval_time, 'DD/MM/YYYY HH24:MI') latest_occur,
  sql_id,
  phash_value,
  nbr_exec,
  ela_sec,
  dreads,
  bgets,
  (ela_sec/nbr_exec) avg_ela_sec,
  (dreads/nbr_exec) avg_dreads,
  (bgets/nbr_exec) avg_bgets
from
  exec_stats,
  dba_hist_snapshot snap1,
  dba_hist_snapshot snap2
where
  exec_stats.min_snap_id = snap1.snap_id
  and exec_stats.instance_number = snap1.instance_number
  and exec_stats.max_snap_id = snap2.snap_id
  and exec_stats.instance_number = snap2.instance_number
;
  