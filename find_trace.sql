column tracefile_name for a120

select 
  ( rtrim(k.value,'/') || '/' || d.instance_name || '_ora_' || p.spid || 
    decode(p.value, '', '', '_' || p.value) || '.trc' 
  ) tracefile_name
from 
  v$parameter       k, 
  v$parameter       p, 
  v$instance        d,
  sys.v_$session    s, 
  sys.v_$process    p,
  ( select 
      sid 
    from
      v$mystat 
    where 
      rownum = 1
  )                 m
where
  p.name = 'tracefile_identifier'
  and k.name = 'user_dump_dest'
  and s.paddr = p.addr
  and s.sid = m.sid
;
