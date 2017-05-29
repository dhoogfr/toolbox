-- list the enabled unified audit policies and the details of all unified audit policies

set linesize 300
set pages 50000



column user_name format a30
column policy_name format a50

select * from audit_unified_enabled_policies;



column policy_name format a25
column audit_condition format a40
column audit_option format a40
column audit_option_type format a20
column object_schema format a30
column object_name format a30
column object_type format a15
column common format a7
column condition_eval_opt format a10 heading EVAL_OPTS

break on policy_name skip 1

select
  policy_name,
  common,
  audit_option_type,
  audit_option,
  object_schema,
  object_name,
  object_type,
  audit_condition,
  condition_eval_opt
from
  audit_unified_policies
--where
--  policy_name in 
--    ( 'ORA_SECURECONFIG', 'ORA_LOGON_FAILURES' )
order by
  policy_name, 
  audit_option_type,
  audit_option
;

clear breaks;
