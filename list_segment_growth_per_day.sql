-- show the allocated delta per day for a given segment

set linesize 200
set pages 50000

column day_str format a10
column object_name format a30
column subobject_name format a30
column owner format a30
column object_type format a20
column allocated_delta_mb format 9G999G999

accept _owner prompt 'Segment Owner: '
accept _segment_name prompt 'Segment Name: '
accept _subsegment_name Prompt 'Sub Segment Name: '

select
  to_char(day, 'DD/MM/YYYY') day_str,
  owner,
  object_name,
  subobject_name,
  object_type,
  allocated_delta_mb
from
  ( select
      trunc(snap.end_interval_time) day,
      obj.owner,
      obj.object_name,
      obj.subobject_name,
      obj.object_type,
      sum(hseg.space_allocated_delta/1024/1024) allocated_delta_mb
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
      obj.owner = '&_owner'
      and obj.object_name = '&_segment_name'
      and ( obj.subobject_name = nvl('&_subsegment_name', obj.subobject_name)
            or obj.subobject_name is null
          )
      and hseg.instance_number = 1
    group by
      trunc(snap.end_interval_time),
      obj.owner,
      obj.object_name,
      obj.subobject_name,
      obj.object_type
  )
order by
  day
;

undef _owner
undef _segment_name
undef _subsegment_name
