set pages 50000
set linesize 300

column con_name format a30
column instance_name format a30
column state format a14
column restricted format a10

select
  con_name,
  instance_name,
  state,
  restricted
from
  dba_pdb_saved_states
order by
  con_name,
  instance_name
;
