column host format a30
column principal format a30
column sdate format a20
column edate format a20
column privilege format a20
column acl format a50
column acl_owner format a30


select
  host,
  lower_port,
  upper_port,
  acl,
  aclid,
  acl_owner
from
  dba_host_acls
order by
  host,
  lower_port,
  upper_port
;


break on host

select
  host,
  ace_order,
  lower_port,
  upper_port,
  principal,
  principal_type,
  privilege,
  to_char(start_date, 'DD/MM/YYYY HH24:MI') sdate,
  to_char(end_date, 'DD/MM/YYYY HH24:MI') edate,
  grant_type,
  inverted_principal
from
  dba_host_aces
order by
  host,
  ace_order
;

clear breaks
