column db_name format a40
column dbsys_name format a50
column db_type format a20

select
  target.target_name            db_name,
  assoc_target.target_name      dbsys_name,
  target.target_type            db_type
from
  mgmt_targets target
    left outer join 
      ( gc$assoc_instances assoc
          inner join 
            mgmt_targets assoc_target
              on ( assoc.source_me_guid = assoc_target.target_guid
                   and assoc.assoc_type = 'relies_on_key_component'
                   and assoc_target.target_type = 'oracle_dbsys'
                 )
      )
      on ( target.target_guid = assoc.dest_me_guid 
         )
where
--  target.target_type in ('oracle_database', 'rac_database')
  target.target_type = 'rac_database'
order by
  target.target_name
;
