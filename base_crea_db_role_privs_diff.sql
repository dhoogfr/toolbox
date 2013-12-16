with 
  grantees_to as 
  ( select 
      distinct 
      connect_by_root(usr.name) username, 
      r_usr.name name 
    from  
      sys.sysauth$@DWHPRD_X3DM_LNK sau, 
      sys.user$@DWHPRD_X3DM_LNK r_usr, 
      sys.user$@DWHPRD_X3DM_LNK usr 
    where 
      sau.privilege# = r_usr.user# 
      and sau.grantee# = usr.user#
    connect by 
      prior privilege# = grantee# 
      start with grantee# in 
        ( select
            user#
          from
            sys.user$@DWHPRD_X3DM_LNK
          where 
            name in 
              ( select 
                  owner
                from
                  dba_objects@DWHPRD_X3DM_LNK
                where 
                  object_type = 'DATABASE LINK'
              )
        )
    union all
    select
      distinct
      owner, 
      owner 
    from
      dba_objects@DWHPRD_X3DM_LNK
    where
      object_type = 'DATABASE LINK'
  ),
  users_to as
  ( select
      distinct 
      owner
    from 
      dba_objects@DWHPRD_X3DM_LNK  a
    where
      object_type = 'DATABASE LINK'
      and not exists
        ( select
            null 
          from 
            uptdba.exclude_oracle_users b 
          where 
            b.user_name = a.owner
        )
    minus
    select
      grt.username
    from
      grantees_to grt, 
      dba_sys_privs@DWHPRD_X3DM_LNK sp
    where
      grt.name = sp.grantee
      and privilege = 'CREATE DATABASE LINK'
  ),
  grantees_from as 
  ( select
      distinct 
       connect_by_root(usr.name) username, 
       r_usr.name name 
    from 
      sys.sysauth$@DWHPRD_LNK sau, 
      sys.user$@DWHPRD_LNK r_usr, 
      sys.user$@DWHPRD_LNK usr 
    where
      sau.privilege# = r_usr.user# 
      and sau.grantee# = usr.user#
    connect by 
      prior privilege# = grantee# 
      start with grantee# in 
        ( select
            user#
          from
            sys.user$@DWHPRD_LNK
          where
            name in 
              ( select 
                  owner
                from
                  dba_objects@DWHPRD_LNK
                where 
                  object_type = 'DATABASE LINK'
              )
        )
    union all
    select
      distinct
      owner, 
      owner 
    from
      dba_objects@DWHPRD_LNK
    where
      object_type = 'DATABASE LINK'
  ),
  users_from as
  ( select
      distinct 
      owner
    from 
      dba_objects@DWHPRD_LNK  a
    where
      object_type = 'DATABASE LINK'
      and not exists
        ( select
            null 
          from 
            uptdba.exclude_oracle_users b 
          where 
            b.user_name = a.owner
        )
    minus
    select
      grt.username
    from
      grantees_from grt, 
      dba_sys_privs@DWHPRD_LNK sp
    where
      grt.name = sp.grantee
      and privilege = 'CREATE DATABASE LINK'
  )
select
  owner
from
  users_to
union
select
  owner
from
  users_from
order by
  owner
;
