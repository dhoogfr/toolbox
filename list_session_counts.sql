column service_name format a25
column machine format a35
column username format a30
break on inst_id skip 2 on service_name skip 1

select inst_id, service_name, machine, username, count(*) counted
from gv$session
where username is not null
group by inst_id, service_name, username, machine
order by inst_id, service_name, username, machine;