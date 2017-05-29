-- list the row level security policies

set linesize 250
set pages 50000

column object_owner format a30
column object_name format a30
column pf_owner format a30
column function format a30
column policy_name format a30
column package format a30

select
  object_owner,
  object_name,
  policy_name,
  pf_owner,
  package,
  function,
  enable,
  sel,
  ins,
  upd,
  del,
  idx
from
  dba_policies
where
  object_owner not in 
    ( 'SYSTEM', 'XDB', 'MDSYS')
order by
  object_owner,
  object_name,
  policy_name
;

