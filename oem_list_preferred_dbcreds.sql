-- list the default DBCreds credentials for the DB targets

select
  tgts.target_name,
  tcreds.set_name,
  creds.cred_name,
  tcreds.target_type,
  tcreds.is_default
from
  em_nc_creds                                         creds
  join em_target_creds_e                              tcreds
    on ( creds.cred_guid = tcreds.cred_guid
       )
  join mgmt$target                                    tgts
    on ( tcreds.target_guid = tgts.target_guid 
       )
where
  creds.cred_type_name = 'DBCreds'
  and creds.cred_scope = 1
--  and tcreds.set_name = 'DBCredsSYSDBA'
  and tcreds.is_default = 0
order by
  tgts.target_name,
  tcreds.set_name
;
