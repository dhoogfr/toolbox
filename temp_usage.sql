set linesize 140
set pagesize 999

column sid format a15
column sql_text format a50 word_wrapped
column size_mb format 9G999D99


select
  u.inst_id,
  s.sid || ',' || s.serial# sid, 
  s.username, u.tablespace, a.sql_text,
  round(((u.blocks*p.value)/1024/1024),2) size_mb
from
  gv$sort_usage      u, 
  gv$session         s, 
  gv$sqlarea         a, 
  v$parameter        p
where 
  s.saddr = u.session_addr
  and s.inst_id = u.inst_id
  and a.address (+) = s.sql_address
  and a.hash_value (+) = s.sql_hash_value
  and a.inst_id (+) = s.inst_id
  and p.name = 'db_block_size'
  and s.username != 'SYSTEM'
group by 
  u.inst_id,
  s.sid || ',' || s.serial#,
  s.username, a.sql_text, u.tablespace, 
  round(((u.blocks*p.value)/1024/1024),2)
;
