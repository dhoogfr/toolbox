column group_name format a30
column target_type format a30
column target_name format a60

break on target_type skip 1

select
  trgt.target_type,
  trgt.target_name,
  nvl(composite_target_name, 'Unassigned') group_name
from
  mgmt$group_derived_memberships gdm,
  mgmt$target trgt
where
  gdm.member_target_guid(+) = trgt.target_guid
  and ( ( trgt.target_type = 'oracle_database' 
          and trgt.type_qualifier3 != 'RACINST'
        )
        or trgt.target_type in ('rac_database', 'host', 'osm_cluster', 'oracle_si_virtual_platform', 'oracle_si_server', 'oracle_exadata_grid')
      )
  and ( composite_target_guid is null 
        or composite_target_guid not in
          ( select
              composite_target_guid
            from
              mgmt$group_derived_memberships
            where
              member_target_type = 'composite'
           )
      )
order by
  target_type,
  target_name,
  group_name
;

clear breaks
