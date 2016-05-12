-- give a tree view of the directly / indirectly granted roles
-- pass the grantee name (user or role) as first argument

set verify off

set pages 50000
set linesize 250

column role format a200 heading "Role"

select
  lpad(' ', 2*level-1) || sys_connect_by_path(usr.name, '/') role
from
  sys.sysauth$  sau,
  sys.user$     usr
where
  sau.privilege# = usr.user#
connect by
  prior privilege# = grantee#
start with
  grantee# =
    ( select
        user#
      from
        sys.user$
      where
        name = '&1'
    )
;

undef 1
