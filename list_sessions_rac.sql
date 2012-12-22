set linesize 200
set pagesize 999
column sid format 9999
column machine format a25
column osuser format a20
column user format a15
column program format a35
column service_name format a20


select instance_name, sid, serial#, username, machine, osuser, program, service_name, failover_type,failover_method,failed_over
from gv$session ses, gv$instance inst
where ses.inst_id = inst.inst_id
      and service_name !='SYS$BACKGROUND'
order by instance_name, sid, serial#;
