set verify off

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
prompt System Privileges
prompt -----------------

select
  privilege, admin_option 
from
  dba_sys_privs 
where
  grantee = '&&grantee'
order by
  privilege
;

prompt
prompt Object Privileges
prompt -----------------

select
  owner, table_name, privilege, grantable, hierarchy 
from
  dba_tab_privs 
where
  grantee = '&&grantee'
order by
  owner, table_name, privilege
;

prompt
prompt Direclty Granted Roles
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
  username = '&&grantee'
order by
  granted_role
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
