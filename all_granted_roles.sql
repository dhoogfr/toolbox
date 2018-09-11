-- show all roles for a user, either directly assigned or nested via other roles

with user_role_hierarchy 
as ( select
       t2.name username, t1.granted_role
     from
       ( select
           distinct sa.userid, u.name granted_role
         from
           ( select
               t.*, connect_by_root grantee# userid
             from
               sys.sysauth$ t
             connect by
               prior privilege# = grantee#
           )            sa,
           sys.user$    u
         where
           u.user# = sa.privilege#
           and sa.userid in 
             ( select
                 user#
               from
                 sys.user$
               where
                 type# = 1  -- normal users
                 or user# = 1  -- PUBLIC
       )
       ) t1,
       sys.user$    t2
     where
       t1.userid = t2.user#
  )
select
  *
from
  user_role_hierarchy
where
  username = '&user'
order by
  granted_role
;
