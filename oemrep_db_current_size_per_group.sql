-- for each database in the repository get the current allocated and used database size 
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column group_name format a20  heading "Group"
column target_name format a40 heading "Database"
column rollup_timestamp_s format a16 heading "Date"
column used_gb format 9G999G999D99 heading "Used Space (GB)"
column allocated_gb format 9G999G999D99 heading "Allocated Space (GB)"

break on group_name skip page on report

compute sum of used_gb on group_name
compute sum of used_gb on report
compute sum of allocated_gb on group_name
compute sum of allocated_gb on report

with latest_sample
as
( select
    target_guid,
    target_name,
    rollup_timestamp,
    metric_column,
    maximum
  from
    ( select
        target_guid,
        target_name,
        rollup_timestamp,
        metric_column,
        maximum,
        row_number() over
          ( partition by target_guid, target_name, metric_column
            order by rollup_timestamp desc
          ) rn
      from
        mgmt$metric_hourly
      where
        target_guid in
          ( select
              target_guid
            from
              mgmt$target
            where
              ( target_type = 'oracle_database' 
                and type_qualifier3 != 'RACINST'
              )
              or target_type = 'rac_database'
          )
        and metric_name = 'DATABASE_SIZE'
    )
  where
    rn = 1
)
select
  group_name,
  target_name,
  to_char(rollup_timestamp, 'DD/MM/YYYY HH24:MI') rollup_timestamp_s,
  allocated_gb,
  used_gb
from
  ( select
      nvl(gdm.composite_target_name, 'Unassigned') group_name,
      ls.target_name,
      ls.rollup_timestamp,
      ls.metric_column,
      ls.maximum
    from
      latest_sample     ls
        left outer join mgmt$group_derived_memberships gdm
          on ( ls.target_guid = gdm.member_target_guid)
    where
      ( gdm.composite_target_guid is null 
        or gdm.composite_target_guid not in
          ( select
              cmp.composite_target_guid
            from
              mgmt$group_derived_memberships  cmp
            where
              cmp.member_target_type = 'composite'
           )
      )
  )
pivot
  ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
order by
  group_name,
  target_name
;

clear breaks
clear computes
