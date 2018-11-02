-- list the top 10 segments based on growth in a given tablespace
-- provide the tablespace name as script argument
--
-- requires the diagnostic pack 

set linesize 200
set pages 50000

column min_snap_time format a30
column max_snap_time format a30
column object_name format a30
column subobject_name format a30
column owner format a30
column object_type format a20
column total_allocated_delta_mb format 9G999G999


select
  *
from
  ( select
      min(snap.begin_interval_time) min_snap_time,
      max(snap.end_interval_time) max_snap_time,
      obj.owner,
      obj.object_name,
      obj.subobject_name,
      obj.object_type,
      sum(hseg.space_allocated_delta)/1024/1024 total_allocated_delta_mb
    from
      dba_hist_seg_stat hseg
        join dba_hist_seg_stat_obj obj
          on ( hseg.dbid = obj.dbid
               and hseg.obj# = obj.obj#
               and hseg.ts# = obj.ts#
             )
        join dba_hist_snapshot snap
          on ( hseg.snap_id = snap.snap_id
               and hseg.instance_number = snap.instance_number
               and hseg.dbid = snap.dbid
             )
        join v$database db
          on ( hseg.dbid = db.dbid )
    where
      -- use this contruct to push the tablespace predicate further down
      -- using a filter on dba_hist_seg_stat_obj itself would only filter on tablespace name as one of the latest steps
      hseg.ts# = (select distinct ts# from dba_hist_seg_stat_obj where tablespace_name = '&1')
    group by
      obj.owner,
      obj.object_name,
      obj.subobject_name,
      obj.object_type
    order by
      total_allocated_delta_mb desc
  )
where
  rownum <= 10
;

undef 1
