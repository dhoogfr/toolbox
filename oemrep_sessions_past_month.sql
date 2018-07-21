-- for each database in the repository, get the logons and average active sessions for the past month
-- summate these per database as well in case of rac databases
---
-- run this as sysman user on the OEM repository database
-- tested with 12c R1 BP1

set linesize 300
set pages 50000
set tab off
set echo off

column db_name format a40 heading "Database"
column rollup_timestamp_s format a10 heading "Day"
column inst_name format a45 heading "Instance"
column inst_logons format 9G999G999
column db_logons format 999G999G999
column inst_avg_active_sess format 9G999G990D99
column db_avg_active_sess format 999G999G990D99

break on db_name skip page on rollup_timestamp_s

select
  db_name,
  to_char(rollup_timestamp, 'DD/MM/YYYY') rollup_timestamp_s,
  inst_name,
  inst_logons,
  inst_avg_active_sess,
  sum(inst_logons) over
    ( partition by db_name, rollup_timestamp
    ) db_logons,
  sum(inst_avg_active_sess) over
    ( partition by db_name, rollup_timestamp
    ) db_avg_active_sess
from
  ( select
      db_name,
      rollup_timestamp,
      inst_name,
      inst_logons,
      inst_avg_active_sess
    from
      ( select
          nvl(rac.composite_target_name, met.target_name) db_name,
          met.target_name  inst_name,
          met.rollup_timestamp,
          met.metric_column,
          met.maximum
        from
          mgmt$metric_daily     met,
          mgmt$rac_memberships  rac
        where
          met.target_guid = rac.member_target_guid (+)
          and ( ( met.metric_name = 'Database_Resource_Usage'
                  and met.metric_column = 'logons'
                )
                or ( met.metric_name = 'instance_throughput'
                     and met.metric_column = 'avg_active_sessions'
                  )
              )
          and met.target_type = 'oracle_database'
          and rollup_timestamp >= add_months(trunc(sysdate), - 1)
      )
    pivot
      ( max(maximum) for metric_column in ('logons' as inst_logons, 'avg_active_sessions' as inst_avg_active_sess))
  )
order by
  db_name,
  rollup_timestamp,
  inst_name
;

clear breaks
