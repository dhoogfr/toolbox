column machine format a20

select inst_id, sid, serial#, machine, process, sql_id, sql_child_number, last_call_et, sql_trace
from gv$session
where service_name = 'NAVIS_TRACING'
order by 1, 2;
