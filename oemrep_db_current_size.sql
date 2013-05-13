-- for each database in the repository get the current allocated and used database size 
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column target_name format a30 heading "Database"
column rollup_timestamp_s format a16 heading "Date"
column used_gb format 9G999G999D99 heading "Used Space (GB)"
column allocated_gb format 9G999G999D99 heading "Allocated Space (GB)"

with latest_sample
as
( select
    target_name,
    rollup_timestamp,
    metric_column,
    maximum
  from
    ( select
        target_name,
        rollup_timestamp,
        metric_column,
        maximum,
        row_number() over
          ( partition by target_name, metric_column
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
  target_name,
  to_char(rollup_timestamp, 'DD/MM/YYYY HH24:MI') rollup_timestamp_s,
  allocated_gb,
  used_gb
from
  ( latest_sample
  )
pivot
  ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
order by
  target_name
;
