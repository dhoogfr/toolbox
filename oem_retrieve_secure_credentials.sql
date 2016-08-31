-- list the OEM secure credentials, including the password itself, together with their associated target (if not public)
-- You can use this script to retrieve all credential values, which is usefull when coming in an environment where people have bad memories
-- run this as sysman user on the OEM repository
-- before running this script, the EM Key needs to be stored in the repository, to this via emctl config emkey -copy_to_repos
-- after the script has finished, remove the emkey again with emctl config emkey -remove_from_rep

-- based upon script from Gokhan Atil http://www.gokhanatil.com/2015/02/em12c-how-to-retrieve-passwords-from-the-named-credentials.html
-- Credits to him !


column cred_owner format a30
column cred_owner format a10
column cred_name format a40
column target_type format a20
column username format a30
column rolename format a30
column credential_pwd format a30
column target_name format a50

select
  *
from
( select
    creds.cred_owner,
    creds.cred_name,
    creds.target_type,
    creds.cred_scope,
    tgts.target_name,
    ( select 
        em_crypto.decrypt(credc.cred_attr_value, credc.cred_salt) 
      from 
        em_nc_cred_columns credc
      where 
        creds.cred_guid  = credc.cred_guid 
        and lower(credc.cred_attr_name) like '%user%'
    ) username,
    ( select 
        em_crypto.decrypt(credc.cred_attr_value, credc.cred_salt) 
      from 
        em_nc_cred_columns credc
      where 
        creds.cred_guid  = credc.cred_guid 
        and lower(credc.cred_attr_name) like '%role%'
    ) rolename,
    ( select 
        em_crypto.decrypt(credc.cred_attr_value, credc.cred_salt) 
      from 
        em_nc_cred_columns credc
      where 
        creds.cred_guid  = credc.cred_guid 
        and lower(credc.cred_attr_name) like '%password%'
    ) credential_pwd
  from
    em_nc_creds creds
      left outer join mgmt$target tgts
       on ( creds.target_guid = tgts.target_guid)
)
where
  credential_pwd is not null
order by 
  cred_owner,
  cred_name
;
