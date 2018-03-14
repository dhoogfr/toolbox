column object_schema format a15
column object_name format a30
column policy_owner format a15
column policy_name format a20
column policy_text format a65

select
  object_schema, 
  object_name, 
  policy_owner, 
  policy_name, 
  policy_text, 
--  policy_column, 
--  pf_schema, 
--  pf_package,
--  pf_function, 
  sel, 
  ins, 
  upd, 
  del, 
  audit_trail, 
  policy_column_options 
from
  dba_audit_policies
where
  enabled= 'YES'
order by
  object_schema,
  object_name
;

