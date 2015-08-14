-- for each database in the repository list per day in the past month the allocated and used database size 
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column target_name format a30 heading "Database"
column rollup_timestamp_s format a10 heading "Day"
column used_gb format 9G999G999D99 heading "Used Space (GB)"
column allocated_gb format 9G999G999D99 heading "Allocated Space (GB)"

break on target_name skip page

select
  target_name,
  to_char(rollup_timestamp, 'DD/MM/YYYY') rollup_timestamp_s,
  allocated_gb,
  used_gb
from
  ( select
      target_name,
      rollup_timestamp,
      metric_column,
      maximum
    from
      mgmt$metric_daily
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
      and trunc(rollup_timestamp) > add_months(sysdate, -1)
  )
pivot
  ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
order by
  target_name,
  rollup_timestamp
;

clear computes
clear breaks
