-- for each database in the repository get the current allocated and used database size 
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column group_name format a20  heading "Group"
column target_name format a30 heading "Database"
column last_collection_s format a16 heading "Last Collection"
column first_collection_s format a16 heading "First Collection"
column last_used_gb format 9G999G990D00 heading "Last Used| Space (GB)"
column last_allocated_gb format 9G999G990D00 heading "Last Allocated| Space (GB)"
column first_used_gb format 9G999G990D00 heading "First Used| Space (GB)"
column first_allocated_gb format 9G999G990D00 heading "First Allocated| Space (GB)"
column days_between format 9990D00 heading "Days Between"
column diff_allocated_gb format 9G999G990D00 heading "Diff Allocated|Space (GB)"
column diff_used_gb format 9G999G990D00 heading "Diff Used Space (GB)"
column diff_allocated_per_day_gb format 9G999G990D00 heading "Daily Diff|Allocated Space (GB)"
column diff_used_per_day_gb format 9G999G990D00 heading "Daily Diff|Used Space (GB)"


break on group_name skip page on report

compute sum of last_used_gb on group_name
compute sum of last_used_gb on report
compute sum of last_allocated_gb on group_name
compute sum of last_allocated_gb on report
compute sum of first_used_gb on group_name
compute sum of first_used_gb on report
compute sum of first_allocated_gb on group_name
compute sum of first_allocated_gb on report
compute sum of diff_used_gb on group_name
compute sum of diff_used_gb on report
compute sum of diff_allocated_gb on group_name
compute sum of diff_allocated_gb on report
compute sum of diff_used_per_day_gb on group_name
compute sum of diff_used_per_day_gb on report
compute sum of diff_allocated_per_day_gb on group_name
compute sum of diff_allocated_per_day_gb on report


with 
latest_sample
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
),
first_sample
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
            order by rollup_timestamp asc
          ) rn
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
    )
  where
    rn = 1
),
latest_sample_p
as
( select
    target_guid,
    target_name,
    rollup_timestamp,
    allocated_gb,
    used_gb
  from
    latest_sample     ls
  pivot
    ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
),
first_sample_p
as
( select
    target_guid,
    target_name,
    rollup_timestamp,
    allocated_gb,
    used_gb
  from
    first_sample     fs
  pivot
    ( max(maximum) for metric_column in ('USED_GB' as USED_GB, 'ALLOCATED_GB' as ALLOCATED_GB))
),
target_samples
as
( select
    lsp.target_guid,
    lsp.target_name,
    lsp.rollup_timestamp                                                                                                last_collection,
    fsp.rollup_timestamp                                                                                                first_collection,
    lsp.allocated_gb                                                                                                    last_allocated_gb,
    fsp.allocated_gb                                                                                                    first_allocated_gb,
    lsp.used_gb                                                                                                         last_used_gb,
    fsp.used_gb                                                                                                         first_used_gb,
    nvl2(fsp.target_guid, (lsp.rollup_timestamp - fsp.rollup_timestamp), null)                                          days_between,
    nvl2(fsp.target_guid, (lsp.allocated_gb - fsp.allocated_gb), null)                                                  diff_allocated_gb,
    nvl2(fsp.target_guid, (lsp.used_gb - fsp.used_gb), null)                                                            diff_used_gb,
    nvl2(fsp.target_guid, (lsp.allocated_gb - fsp.allocated_gb)/(lsp.rollup_timestamp - fsp.rollup_timestamp), null)    diff_allocated_per_day_gb,
    nvl2(fsp.target_guid, (lsp.used_gb - fsp.used_gb)/(lsp.rollup_timestamp - fsp.rollup_timestamp), null)              diff_used_per_day_gb
  from
    latest_sample_p   lsp
      left outer join first_sample_p    fsp
        on ( lsp.target_guid = fsp.target_guid )
)
select
  nvl(gdm.composite_target_name, 'Unassigned') group_name,
  ts.target_name,
  to_char(ts.last_collection, 'DD/MM/YYYY HH24:MI') last_collection_s,
  to_char(ts.first_collection, 'DD/MM/YYYY HH24:MI') first_collection_s,
  ts.last_allocated_gb,
  ts.first_allocated_gb,
  ts.last_used_gb,
  ts.first_used_gb,
  ts.days_between,
  ts.diff_allocated_gb,
  ts.diff_used_gb,
  ts.diff_allocated_per_day_gb,
  ts.diff_used_per_day_gb
from
  target_samples     ts
    left outer join mgmt$group_derived_memberships gdm
      on ( ts.target_guid = gdm.member_target_guid)
where
  gdm.composite_target_guid is null 
  or gdm.composite_target_guid not in
    ( select
        cmp.composite_target_guid
      from
        mgmt$group_derived_memberships  cmp
      where
        cmp.member_target_type = 'composite'
     )
order by
  group_name,
  target_name
;

clear breaks
clear computes
