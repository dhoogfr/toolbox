with grantees as 
  ( select
      distinct
      connect_by_root(usr.name)     username,
      r_usr.name                    name
    from
      sys.sysauth$  sau,
      sys.user$     r_usr,
      sys.user$     usr
    where
      sau.privilege# = r_usr.user#
      and sau.grantee# = usr.user#
    connect by
      prior privilege# = grantee#
    start with
      grantee# in
        ( select
            user#
          from
            sys.user$
          where
            name in
              ( select
                  owner
                from
                  dba_objects
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
      dba_objects
    where
      object_type = 'DATABASE LINK'
  )
select
  distinct
  owner
from
  dba_objects
where
   object_type = 'DATABASE LINK'
minus
select
  grt.username
from
  grantees          grt,
  dba_sys_privs     sp
where
  grt.name = sp.grantee
  and privilege = 'CREATE DATABASE LINK'
order by
  owner
;
