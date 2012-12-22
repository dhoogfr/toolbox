select 
  px.sid, p.pid, p.spid, px.inst_id,
  px.server_group, px.server_set, px.degree, 
  px.req_degree, w.event
from
  gv$session        s, 
  gv$px_session     px, 
  gv$process        p, 
  gv$session_wait   w
where
  s.sid (+) = px.sid 
  and s.inst_id (+) = px.inst_id 
  and s.sid = w.sid (+) 
  and s.inst_id = w.inst_id (+) 
  and s.paddr = p.addr (+) 
  and s.inst_id = p.inst_id (+)
order by 
  decode(px.qcinst_id,  null, px.inst_id,  px.qcinst_id), 
  px.qcsid, 
  decode(px.server_group, null, 0, px.server_group), 
  px.server_set, 
  px.inst_id;


col inst_id     format 999          heading "Inst ID"
col name        format a50          heading "Name"
col value       format 9G999G999    heading "Value"
 
break on inst_id skip 1

select 
  inst_id, 
  name, 
  value 
from
  gv$sysstat
where 
  name like '%Parallel operations %'
  or name like '%parallelized%'
order by 
  inst_id, 
  name
;

clear breaks
