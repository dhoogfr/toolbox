-- for the current top 10 segments (by size) list the history of the space used / allocated delta per day for the past month.
-- as dba_hist_seg_stat does not contain all segments, but only the ones that oracle determines to to be interesting, the history may be lacking or incomplete for some of the segments
-- also, default the history in dba_hist_seg_stat is only kept for 7 days

column owner format a30 heading "Owner"
column segment_name format a30 heading "Segment"
column segment_type format a18 heading "Type"
column tablespace_name format a30 heading "Tablespace"
column begin_interval_day_s format a10 heading "Day"
column current_size_mb format 999G999G990D99 heading "Curr Size (MB)"
column space_used_delta_mb format 999G999G990D99 heading "Space Used Delta (MB)"
column space_allocated_delta_mb format 999G999G990D99 heading "Space Alloc Delta (MB)"

break on owner on segment_name skip 1 on segment_type on tablespace_name on current_size_mb

with ctop
as
( select
    *
  from
    ( select
        owner,
        segment_name,
        partition_name,
        segment_type,
        tablespace_name,
        bytes
      from
        dba_segments
      where
        segment_type not in ('ROLLBACK', 'TEMPORARY', 'TYPE2 UNDO')
      order by
        bytes desc
    )
  where
    rownum <= 10
),
segstat
as
( select
    trunc(snap.begin_interval_time) begin_interval_day,
    obj.owner,
    obj.object_name,
    obj.subobject_name,
    sum(stat.space_used_delta) space_used_delta,
    sum(stat.space_allocated_delta) space_allocated_delta
  from
    dba_hist_snapshot       snap,
    dba_hist_seg_stat       stat,
    dba_hist_seg_stat_obj   obj
  where
    snap.dbid = stat.dbid
    and snap.snap_id = stat.snap_id
    and snap.instance_number = stat.instance_number
    and stat.dbid = obj.dbid
    and stat.obj# = obj.obj#
    and snap.begin_interval_time >= add_months(trunc(sysdate), -1)
  group by
    trunc(snap.begin_interval_time),
    obj.owner,
    obj.object_name,
    obj.subobject_name
)
select
  ctop.owner,
  ctop.segment_name,
  ctop.segment_type,
  ctop.tablespace_name,
  ctop.bytes/1024/1024 current_size_mb,
  to_char(segstat.begin_interval_day, 'DD/MM/YYYY') begin_interval_day_s,
  segstat.space_used_delta/1024/1024 space_used_delta_mb,
  segstat.space_allocated_delta/1024/1024 space_allocated_delta_mb
from
  ctop,
  segstat
where
  ctop.segment_name = segstat.object_name(+) 
  and nvl(ctop.partition_name, 'x') = nvl(segstat.subobject_name,'x')
order by
  ctop.bytes desc,
  ctop.owner,
  ctop.segment_name,
  ctop.partition_name,
  segstat.begin_interval_day
;

clear breaks
