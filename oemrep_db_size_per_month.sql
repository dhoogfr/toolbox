-- for each database in the repository, get the allocated and used diskspace at the beginning and end of the month over the past year and calculate the difference between and the (running) average difference
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column target_name format a30 heading "Database"
column rollup_month_s format a10 heading "Month"
column first_used_gb format 9G999G990D99 heading "First Used Space (GB)"
column last_used_gb format 9G999G990D99 heading "Last Used Space (GB)"
column first_allocated_gb format 9G999G990D99 heading "First Allocated Space (GB)"
column last_allocated_gb format 9G999G990D99 heading "Last Allocated Space (GB)"
column allocated_diff_gb format 99G990D99 heading "Diff Allocated (GB)"
column used_diff_gb format 99G990D99 heading "Diff Used (GB)"
column avg_allocated_diff_gb format 99G990D99 heading "Avg Diff Allocated (GB)"
column avg_used_diff_gb format 99G990D99  heading "Avg Diff used (GB)"

break on target_name skip page

with daily_stats
as
( select
    target_name,
    rollup_timestamp,
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
        and trunc(rollup_timestamp) > add_months(sysdate, -12)
    )
  pivot
    ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
)
select
  target_name,
  to_char(rollup_month, 'DD/MM/YYYY') rollup_month_s,
  first_allocated_gb,
  last_allocated_gb,
  (last_allocated_gb - first_allocated_gb) allocated_diff_gb,
  avg(last_allocated_gb - first_allocated_gb) over
    ( partition by target_name
      order by rollup_month
      rows between unbounded preceding and current row
    ) avg_allocated_diff_gb,
  first_used_gb,
  last_used_gb,
  (last_used_gb - first_used_gb) used_diff_gb,
  avg(last_used_gb - first_used_gb) over
    ( partition by target_name
      order by rollup_month
      rows between unbounded preceding and current row
    ) avg_used_diff_gb
from
  ( select
      target_name,
      rollup_month,
      first_allocated_gb,
--      last_allocated_gb,
      lead(first_allocated_gb, 1) over
        ( partition by target_name
          order by rollup_month
        ) last_allocated_gb,
      first_used_gb,
--      last_used_gb
      lead(first_used_gb, 1) over
        ( partition by target_name
          order by rollup_month
        ) last_used_gb
    from
      ( select
          target_name,
          trunc(rollup_timestamp, 'MM') rollup_month,
          first_value(allocated_gb) over
            ( partition by target_name, trunc(rollup_timestamp, 'MM')
              order by rollup_timestamp
              rows between unbounded preceding and unbounded following
            ) first_allocated_gb,
--          last_value(allocated_gb) over
--            ( partition by target_name, trunc(rollup_timestamp, 'MM')
--              order by rollup_timestamp
--              rows between unbounded preceding and unbounded following
--            ) last_allocated_gb,
          first_value(used_gb) over
            ( partition by target_name, trunc(rollup_timestamp, 'MM')
              order by rollup_timestamp
              rows between unbounded preceding and unbounded following
            ) first_used_gb
--          last_value(used_gb) over
--            ( partition by target_name, trunc(rollup_timestamp, 'MM')
--              order by rollup_timestamp
--              rows between unbounded preceding and unbounded following
--            ) last_used_gb
        from
          daily_stats
      )
    group by
      target_name,
      rollup_month,
      first_allocated_gb,
--      last_allocated_gb,
      first_used_gb
--      last_used_gb
  )      
order by
  target_name,
  rollup_month
;

clear breaks;
