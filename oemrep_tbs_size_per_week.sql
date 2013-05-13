-- for each database in the repository, get the allocated and used size per tablespace at the beginning and end of the week over the past month and calculate the difference between and the (running) average difference
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column target_name format a30 heading "Database"
column rollup_week_s format a10 heading "Week"
column rollup_week_nbr format 99 heading "Nr"
column tbs_name format a30 heading "Tablespace"
column first_used_mb format 9G999G990D99 heading "First Used|Space (MB)"
column last_used_mb format 9G999G990D99 heading "Last Used|Space (MB)"
column first_allocated_mb format 9G999G990D99 heading "First Allocated|Space (MB)"
column last_allocated_mb format 9G999G990D99 heading "Last Allocated|Space (MB)"
column allocated_diff_mb format 999G990D99 heading "Diff Allocated|(MB)"
column used_diff_mb format 999G990D99 heading "Diff Used|(MB)"
column avg_allocated_diff_mb format 999G990D99 heading "Avg Diff|Allocated (MB)"
column avg_used_diff_mb format 999G990D99  heading "Avg Diff|Used (MB)"

break on target_name skip page on tbs_name skip 1

with daily_stats
as
( select
    target_name,
    rollup_timestamp,
    tbs_name,
    allocated_mb,
    used_mb
  from
    ( select
        target_name,
        rollup_timestamp,
        key_value tbs_name,
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
        and metric_name = 'tbspAllocation'
        and trunc(rollup_timestamp) > add_months(sysdate, -1)
    )
  pivot
    ( max(maximum) for metric_column in ('spaceUsed' as USED_MB, 'spaceAllocated' as ALLOCATED_MB))
)
select
  target_name,
  to_char(rollup_week, 'DD/MM/YYYY') rollup_week_s,
  to_char(rollup_week, 'IW') rollup_week_nbr,
  tbs_name,
  first_allocated_mb,
  last_allocated_mb,
  (last_allocated_mb - first_allocated_mb) allocated_diff_mb,
  avg(last_allocated_mb - first_allocated_mb) over
    ( partition by target_name, tbs_name
      order by rollup_week
      rows between unbounded preceding and current row
    ) avg_allocated_diff_mb,
  first_used_mb,
  last_used_mb,
  (last_used_mb - first_used_mb) used_diff_mb,
  avg(last_used_mb - first_used_mb) over
    ( partition by target_name, tbs_name
      order by rollup_week
      rows between unbounded preceding and current row
    ) avg_used_diff_mb
from
  ( select
      target_name,
      tbs_name,
      rollup_week,
      first_allocated_mb,
      lead(first_allocated_mb, 1) over
        ( partition by target_name, tbs_name
          order by rollup_week
        ) last_allocated_mb,
      first_used_mb,
      lead(first_used_mb, 1) over
        ( partition by target_name, tbs_name
          order by rollup_week
        ) last_used_mb
    from
      ( select
          target_name,
          trunc(rollup_timestamp, 'IW') rollup_week,
          tbs_name,
          first_value(allocated_mb) over
            ( partition by target_name, tbs_name, trunc(rollup_timestamp, 'IW')
              order by rollup_timestamp
              rows between unbounded preceding and unbounded following
            ) first_allocated_mb,
          first_value(used_mb) over
            ( partition by target_name, tbs_name, trunc(rollup_timestamp, 'IW')
              order by rollup_timestamp
              rows between unbounded preceding and unbounded following
            ) first_used_mb
        from
          daily_stats
      )
    group by
      target_name,
      rollup_week,
      tbs_name,
      first_allocated_mb,
      first_used_mb
  )      
order by
  target_name,
  tbs_name,
  rollup_week
;

clear breaks;
