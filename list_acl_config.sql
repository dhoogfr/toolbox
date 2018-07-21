column host format a30
column acl format a50
column acl_owner format a30

select
  aclid,
  acl,
  host,
  lower_port,
  upper_port,
  acl_owner
from
  dba_network_acls
order by
  host,
  acl
;


column principal format a30
column sdate format a20
column edate format a20
column privilege format a20

break on aclid skip 1

select
  aclid,
  acl,
  principal,
  privilege,
  is_grant,
  invert,
  to_char(start_date, 'DD/MM/YYYY HH24:MI') sdate,
  to_char(end_date, 'DD/MM/YYYY HH24:MI') edate,
  acl_owner
from
  dba_network_acl_privileges
order by
  aclid,
  principal,
  privilege
;

clear breaks
