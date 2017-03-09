set pages 50000
set linesize 300

set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column container_name format a30
column sid format a30
column parameter_name format a40
column parameter_value format a50 word_wrapped

break on container_name duplicates skip 1

select
  con.name container_name, 
  sp.sid, 
  sp.name parameter_name, 
  value$ parameter_value 
from
  pdb_spfile$   sp, 
  v$containers  con 
where
  sp.pdb_uid = con.con_uid
  and con.name like nvl('&1', '%')
order by
  con.name, 
  sp.name
;

clear breaks
undef 1
