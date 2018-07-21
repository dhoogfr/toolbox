-- give information on the own session without needing additional privs
-- credits to Uwe Hesse
--
-- changed to use select from dual instead of dbms_output

column username format a30
column sid format a8
column current_schema format a30
column instance_name format a15
column pdb_name format a15
column database_role format a20
column os_user format a20
column client_ip format a20
column server_hostname format a20
column client_hostname format a20

select 
  sys_context('userenv','session_user') as username,
  sys_context('userenv','sid') as sid,
  sys_context('userenv','current_schema') as current_schema,
  sys_context('userenv','instance_name') as instance_name,
  sys_context('userenv','con_name') as pdb_name,
  sys_context('userenv','database_role') as database_role,
  sys_context('userenv','os_user') as os_user,
  sys_context('userenv','ip_address') as client_ip,
  sys_context('userenv','host') as client_hostname,
  sys_context('userenv','server_host') as server_hostname
from
  dual
;

