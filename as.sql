set pagesize 999
set lines 150
col username format a13
col prog format a10 trunc
col sql_text format a41 trunc
col sid format 9999
col child for 99999
col avg_etime for 999,999.99
select sid, substr(program,1,19) prog, address, hash_value, b.sql_id, child_number child, plan_hash_value, executions execs, 
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime, 
sql_text
from v$session a, v$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.sql_child_number = b.child_number
and sql_text not like 'select sid, substr(program,1,19) prog, address, hash_value, b.sql_id, child_number child,%' -- don't show this query
order by sql_id, sql_child_number
/
