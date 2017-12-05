column owner format a30
column object_name format a30
column subobject_name format a30
column statistic_name format a30
column object_type format a20
column value format 9G999G999G999G990D00
column name format a30 heading "(P)DB NAME"

break on statistic_name skip 1

select
  statistic_name,
  name,
  owner,
  object_name,
  subobject_name,
  object_type,
  value
from
  ( select
      segstat.statistic_name,
      con.name,
      segstat.owner,
      segstat.object_name,
      segstat.subobject_name,
      segstat.object_type,
      segstat.value,
      row_number() 
        over ( partition by statistic_name 
               order by value desc
             ) rn
    from
      v$segment_statistics    segstat
        join v$containers     con
          on ( segstat.con_id = con.con_id )
    where
      statistic_name in
        ( 'physical writes', 'physical reads', 'physical reads direct', 'physical writes direct', 
          'logical reads', 'segment scans'
        )
  )
where
  rn <= 5
order by
  statistic_name,
  rn
;

clear breaks
