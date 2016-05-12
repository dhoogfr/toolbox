set linesize 250
set pages 50000

col plan                    format a30                  heading "Plan Name"
col mgmt_method             format a10                  heading "MGMT|Method"
col status                  format a10                  heading "Status"
col sub_plan                format a8                   heading "Sub Plan"
col num_plan_directives     format 999                  heading "Directives"
col comments                format a50 word_wrapped     heading "Comments"

select
  plan, 
  mgmt_method,
  status, 
  sub_plan, 
  num_plan_directives, 
  comments
from
  dba_rsrc_plans
order by
  plan
;

col name        format a25                  heading "Category Name"
col status      format a10                  heading "Status"
col mandatory   format a5                   heading "Mandatory"
col comments    format a100 word_wrapped    heading "Comment"

select
  name,
  status,
  mandatory,
  comments
from 
  dba_rsrc_categories
order by
  name
;

col consumer_group_id   format 999999               heading "Consumer|ID"
col consumer_group      format a30                  heading "Consumer|Group"
col mgmt_method         format a15                  heading "MGMT Method"
col internal_use        format a8                   heading "Internal|Only"
col category            format a25                  heading "Category Name"
col status              format a10                  heading "Status"
col mandatory           format a9                   heading "Mandatory"
col comments            format a70 word_wrapped     heading "Comment"

select
  consumer_group,
  mgmt_method,
  internal_use,
  category,
  mandatory,
  status,
  comments
from
  dba_rsrc_consumer_groups
order by
  consumer_group
;

col plan                        format a30          heading "Plan Name"
col group_or_subplan            format a30          heading "Consumer Group|Sub-Plan"
col mgmt_p1                     format 999          heading "MGMT|P1"
col mgmt_p2                     format 999          heading "MGMT|P2"
col mgmt_p3                     format 999          heading "MGMT|P3"
col mgmt_p4                     format 999          heading "MGMT|P4"
col mgmt_p5                     format 999          heading "MGMT|P5"
col mgmt_p6                     format 999          heading "MGMT|P6"
col mgmt_p7                     format 999          heading "MGMT|P7"
col mgmt_p8                     format 999          heading "MGMT|P8"
col utilization_limit           format 999          heading "UTL|LIM"
col queueing_p1                 format 99999        heading "Queueing|TimeOut"
col parallel_target_percentage  format 999          heading "Parallel|Target %"
col parallel_degree_limit_p1    format 99999        heading "Parallel|Limit"
col active_sess_pool_p1         format 999999       heading "Session|Limit"
col status                      format a10          heading "Status"

break on plan skip page

select
  plan,
  type,
  group_or_subplan,
--  cpu_p1,
--  cpu_p2,
--  cpu_p3,
--  cpu_p4,
--  cpu_p5,
--  cpu_p6,
--  cpu_p7,
--  cpu_p8,
  mgmt_p1,
  mgmt_p2,
  mgmt_p3,
  mgmt_p4,
  mgmt_p5,
  mgmt_p6,
  mgmt_p7,
  mgmt_p8,
  utilization_limit,
  parallel_degree_limit_p1,
  parallel_target_percentage,
  queueing_p1,
  active_sess_pool_p1,
  status
from
  dba_rsrc_plan_directives
order by
  plan,
  type desc,
  group_or_subplan
;

clear breaks

column plan     format a40      heading "Plan Name or Consumer Group"
column type     format a15      heading "Type"

column break1   noprint

break on break1 skip page

with plan_directives as
  ( select
      plan, group_or_subplan, type
    from
      dba_rsrc_plan_directives
    union
    select
      plan, plan, 'TOP'
    from
      dba_rsrc_plans
    where
      sub_plan = 'NO'
  )    
select
  lpad(' ',(level -1)*2, '-') || decode (pd.type, 'TOP', pd.plan, pd.group_or_subplan) plan,
  decode(type, 'TOP', NULL, type) type,
  level,
  connect_by_root(pd.plan) break1
from
  plan_directives   pd
start with
  pd.type = 'TOP'
connect by nocycle
  pd.plan = prior pd.group_or_subplan
order siblings by
  pd.plan,
  pd.type desc
;

clear breaks
column break1 clear

col priority        format 9999     heading "Priority"
col attribute       format a25      heading "Session Attribute"
col status          format a10      heading "Status"

select
  priority,
  attribute,
  status
from
  dba_rsrc_mapping_priority
order by
  priority,
  attribute
;

col consumer_group      format a30      heading "Consumer Group"
col attribute           format a25      heading "Session Attribute"
col value               format a30      heading "Attribute Value"
col status              format a10      heading "Status"

break on consumer_group skip 1

select
  consumer_group,
  attribute,
  value,
  status
from
  dba_rsrc_group_mappings
order by
  consumer_group,
  attribute,
  value
;

clear breaks

column grantee          format a30  heading "User"
column granted_group    format a30  heading "Consumer Group"
column grant_option     format a6   heading "Grant|Option"
column initial_group    format a7   heading "Initial|Group"

break on grantee

select
  grantee,
  granted_group,
  grant_option,
  initial_group
from
  dba_rsrc_consumer_group_privs
order by
  grantee,
  granted_group
;  
  
clear breaks

column grantee          format a30  heading "User|Role"
column privilege        format a40  heading "Privilege"
column admin_option     format a6   heading "Admin|Option"

select
  grantee,
  privilege,
  admin_option
from
  dba_rsrc_manager_system_privs
order by
  grantee,
  privilege
;

column inst_id      format 9999     heading "Instance"
column value        format a30      heading "Plan Name"

select
  inst_id, value
from
  gv$parameter
where
  name = 'resource_manager_plan' 
order by
  inst_id
;

-- job classes

column job_class_name format a30
column resource_consumer_group format a40
column service format a40
select
  job_class_name,
  resource_consumer_group,
  service
from
  dba_scheduler_job_classes
where
  job_class_name not like 'ORA$AT%'
  and job_class_name not in
    ( 'AQ$_PROPAGATION_JOB_CLASS', 'XMLDB_NFS_JOBCLASS', 'SCHED$_LOG_ON_ERRORS_CLASS', 'DBMS_JOB$', 'DEFAULT_JOB_CLASS')
order by
 job_class_name
/
