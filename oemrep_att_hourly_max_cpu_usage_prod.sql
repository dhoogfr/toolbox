/* hourly max cpu usage by the databases in the MIC and PRD groups, hosted on the x4-2 exadata
   can be used as template for other customers, but group namings and host names would require changes
*/

set linesize 600

column host_name format a30 heading "Host Name"
--column cpu_count format 999 heading "Num OS CPUs"
column virtual format a7 heading "Virtual|Guest"
column cpu_sockets format 999 heading "Num CPU|Sockets"
column cpu_cores format 999 heading "Num CPU|Cores"
column logical_cpus format 999 heading "Num CPU|Threads"
column rollup_timestamp_s format a16 heading "Date"
column bi_mic_max_cpups format 999G990D000 heading "BI-Mic|ps (cs)"
column dots_mic_max_cpups format 999G990D000 heading "Dotc-Mic|ps (cs)"
column dots_prd_max_cpups format 999G990D000 heading "Dots-Prd|ps (cs)"
column evol_mic_max_cpups format 999G990D000 heading "Evol-Mic|ps (cs)"
column eval_prd_max_cpups format 999G990D000 heading "Evol-Prd|ps (cs)"
column infra_prd_max_cpups format 999G990D000 heading "Infra-Prd|ps (cs)"
column misc_mic_max_cpups format 999G990D000 heading "Misc-Mic|ps (cs)"
column misc_prd_max_cpups format 999G990D000 heading "Misc-Prd|ps (cs)"
column syn_prd_max_cpups format 999G990D000 heading "Syn-Prd|ps (cs)"
column total_max_cpups format 999G990D000 heading "Total|ps (cs)"
column avg_cpu_load format 990D00 heading "Max CPU|Load %"
break on host_name dup skip page

with 
prd_db_usage as
( select
    hws.host_name, 
--    hws.cpu_count,
    hws.virtual,
    hws.physical_cpu_count,
    hws.total_cpu_cores,
    hws.logical_cpu_count,
    met.rollup_timestamp,
    gdm.composite_target_name group_name,
    -- tgt.target_guid,
    -- tgt.target_name,
    -- sum(met.average) sum_avg_cpuusage_ps,
    -- sum(met.minimum) sum_min_cpuusage_ps,
    sum(met.maximum) sum_max_cpuusage_ps
  from
    mgmt$target tgt
      join mgmt$os_hw_summary   hws
        on ( hws.host_name = tgt.host_name )
      join mgmt$metric_hourly met
        on ( tgt.target_guid = met.target_guid)
      join mgmt$group_derived_memberships gdm
        on ( tgt.target_guid = gdm.member_target_guid)
  where
    tgt.target_type = 'oracle_database' 
    and met.metric_name = 'instance_efficiency'
    and met.metric_column = 'cpuusage_ps'
    and ( gdm.composite_target_name like '%-MIC-Grp'
          or gdm.composite_target_name like '%-PRD-Grp'
        )
    and tgt.host_name in ('sdtcsynx4adb01.localwan.net', 'sdtcsynx4adb02.localwan.net')
  group by
    hws.host_name,
--    hws.cpu_count,
    hws.virtual,
    hws.physical_cpu_count,
    hws.total_cpu_cores,
    hws.logical_cpu_count,
    gdm.composite_target_name,
    met.rollup_timestamp
),
prd_db_usage_p as
( select
    *
  from
    prd_db_usage
  pivot
    ( -- sum(sum_avg_cpuusage_ps) as avg_cpups,
      -- sum(sum_min_cpuusage_ps) as min_cpups,
      sum(sum_max_cpuusage_ps) as max_cpups
        for group_name in 
          ( 'bi-MIC-Grp' as BI_MIC, 
            --'bi-PRD-Grp' as BI_PRD, 
            'dots-MIC-Grp' as DOTS_MIC, 'dots-PRD-Grp' as DOTS_PRD, 'evol-MIC-Grp' as EVOL_MIC, 
            'evol-PRD-Grp' as EVAL_PRD, 
            -- 'infra-MIC-Grp' as INFRA_MIC, 
            'infra-PRD-Grp' as INFRA_PRD, 'misc-MIC-Grp' as MISC_MIC, 
            'misc-PRD-Grp' as MISC_PRD, 
            -- 'syn-MIC-Grp' as SYN_MIC, 
            'syn-PRD-Grp' as SYN_PRD
          )
    )
)
select
  host_name,
--  cpu_count,
  virtual,
  physical_cpu_count  cpu_sockets,
  total_cpu_cores     cpu_cores,
  logical_cpu_count   logical_cpus,
  to_char(rollup_timestamp, 'DD/MM/YYYY HH24:MI') rollup_timestamp_s,
  bi_mic_max_cpups,
  dots_mic_max_cpups,
  dots_prd_max_cpups,
  evol_mic_max_cpups,
  eval_prd_max_cpups,
  infra_prd_max_cpups,
  misc_mic_max_cpups,
  misc_prd_max_cpups,
  syn_prd_max_cpups,
  ( nvl(bi_mic_max_cpups,0) +
    nvl(dots_mic_max_cpups,0) +
    nvl(dots_prd_max_cpups,0) +
    nvl(evol_mic_max_cpups,0) +
    nvl(eval_prd_max_cpups,0) +
    nvl(infra_prd_max_cpups,0) +
    nvl(misc_mic_max_cpups,0) +
    nvl(misc_prd_max_cpups,0) +
    nvl(syn_prd_max_cpups,0)
  ) total_max_cpups,
  ( ( nvl(bi_mic_max_cpups,0) +
      nvl(dots_mic_max_cpups,0) +
      nvl(dots_prd_max_cpups,0) +
      nvl(evol_mic_max_cpups,0) +
      nvl(eval_prd_max_cpups,0) +
      nvl(infra_prd_max_cpups,0) +
      nvl(misc_mic_max_cpups,0) +
      nvl(misc_prd_max_cpups,0) +
      nvl(syn_prd_max_cpups,0)
    ) / total_cpu_cores
  ) avg_cpu_load
from
  prd_db_usage_p
order by
  host_name,
  rollup_timestamp
;

clear breaks
