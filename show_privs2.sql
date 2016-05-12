set verify off

set linesize 200
set pages 50000

prompt
accept grantee prompt Grantee:
prompt

column account_status format a20
column creation_date format a20
column tablespac_name format a20
column profile format a15

select
  to_char(created, 'DD/MM/YYYY HH24:MI:SS') creation_date,
  account_status, profile, default_tablespace, authentication_type, 
  to_char(expiry_date, 'DD/MM/YYYY') expiry_date
from
  dba_users
where
  username = '&&grantee'
;


prompt
prompt All System Privileges
prompt ---------------------

column grantee format a30 heading "Grantee"
column grantee_type format a10 heading "Type"
column privilege format a40 heading "Privilege"
column admin_option format a10 heading "Admin"

break on grantee skip 1 on grantee_type

with grantees as 
  ( select
      distinct
      connect_by_root(usr.name)     username,
      r_usr.name                    name,
      'Role'                        grantee_type
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
            name = '&&grantee'
        )
    union all
    select
      name, name, 'User'
    from
      sys.user$
    where
      name = '&&grantee'
  )
select
  sp.grantee, grt.grantee_type, sp.privilege, sp.admin_option
from
  grantees          grt,
  dba_sys_privs     sp
where
  grt.name = sp.grantee
order by
  sp.grantee,
  sp.privilege
;

clear breaks

prompt
prompt All Object Privileges
prompt ---------------------

column grantee format a30 heading "Grantee"
column grantee_type format a10 heading "Type"
column owner format a30 heading "Owner"
column table_name format a40 heading "Object"
column privilege format a40 heading "Privilege"
column admin_option format a10 heading "Admin"

break on grantee skip 1 on grantee_type on owner on table_name

with grantees as 
  ( select
      distinct
      connect_by_root(usr.name)     username,
      r_usr.name                    name,
      'Role'                        grantee_type
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
            name = '&&grantee'
        )
    union all
    select
      name, name, 'User'
    from
      sys.user$
    where
      name = '&&grantee'
  )
select
  tp.grantee, grt.grantee_type, tp.owner, tp.table_name, 
  tp.privilege, tp.grantable, tp.hierarchy
from
  grantees          grt,
  dba_tab_privs     tp
where
  grt.name = tp.grantee
order by
  tp.grantee,
  tp.owner,
  tp.table_name,
  tp.privilege
;

clear breaks

prompt
prompt Directly Granted Roles
prompt -----------------------

select
  granted_role, admin_option, default_role
from
  dba_role_privs
where
  grantee = '&&grantee'
order by
  granted_role
;

prompt
prompt All Granted Roles
prompt -----------------

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
        name = '&&grantee'
    )
;


prompt
prompt TS Quotas
prompt -----------------

select
  tablespace_name, max_bytes, dropped
from
  dba_ts_quotas
where
  username = '&&grantee'
order by
  tablespace_name
;


prompt
prompt Objects
prompt -------

break on tablespace_name skip 1

select
  seg.tablespace_name, obj.object_type, count(*) counted
from
  dba_objects   obj,
  dba_segments  seg
where
  obj.owner = seg.owner(+)
  and obj.object_name = seg.segment_name(+)
  and obj.owner = '&&grantee'
group by
  seg.tablespace_name, obj.object_type
order by
  seg.tablespace_name nulls last, obj.object_type
;

clear breaks;

undef grantee
