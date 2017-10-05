set linesize 300

column host_name format a30 heading "Host Name"
column mem format 999G999G999 heading "Physical Mem"
column group_name format a20 heading "Group"
column cpu_count format 999 heading "Num OS CPUs"
column db_instance format a40 heading "DB Instance"
column sga_total format 9G999G999D99 heading "SGA (MB)"
column pga_total format 9G999G999D99 heading "PGA (MB)"


break on host_name skip page on group_name skip 1 on mem on cpu_count

compute sum of sga_total on host_name
compute sum of pga_total on host_name
compute sum of sga_total on group_name
compute sum of pga_total on group_name


with pga_total
as 
( select
    target_guid,
    to_number(value) pga_total,
    collection_timestamp
  from
    mgmt$metric_current mcur
  where
    metric_name = 'memory_usage_sga_pga'
    and metric_column = 'pga_total'
    and target_type = 'oracle_database'
),
sga_total 
as
( select
    target_guid,
    to_number(value) sga_total,
    collection_timestamp
  from
    mgmt$metric_current mcur
  where
    metric_name = 'memory_usage_sga_pga'
    and metric_column = 'sga_total'
    and target_type = 'oracle_database'
)
select
  h.host_name, 
  h.mem, 
  h.cpu_count,
  nvl(gdm.composite_target_name, 'Unassigned') group_name,
  t.target_name db_instance,
  st.sga_total,
  pt.pga_total
from
  mgmt$target t
    join pga_total pt
      on ( t.target_guid = pt.target_guid )
    join sga_total st
      on ( t.target_guid = st.target_guid )
    join mgmt$os_hw_summary h
      on ( h.host_name = t.host_name )
    left outer join mgmt$group_derived_memberships gdm
      on ( t.target_guid = gdm.member_target_guid)
where 
  t.target_type = 'oracle_database'
  and ( gdm.composite_target_guid is null 
        or gdm.composite_target_guid not in
          ( select
              cmp.composite_target_guid
            from
              mgmt$group_derived_memberships  cmp
            where
              cmp.member_target_type = 'composite'
           )
      )
order by
  h.host_name,
  group_name,
  t.target_name
;

clear breaks
clear computes
