REM
REM This healthcheck script is for use on Oracle10gR2 databases only.
REM 
REM
REM Do not use this script on Oracle9iR2 or Oracle 10gR1 Streams configurations.
REM
REM  It  is recommended to run with markup html ON (default is on) and generate an HTML file for web viewing.
REM  Please provide the output in HTML format when Oracle (support or development) requests healthcheck output.
REM  To convert output to a text file viewable with a text editor, 
REM    change the HTML ON to HTML OFF in the set markup command
REM  Remember to set up a spool file to capture the output
REM

--connect / as sysdba
set markup HTML ON entmap off


alter session set nls_date_format='HH24:Mi:SS MM/DD/YY';
set heading off

select 'STREAMS Health Check (V3.0.26) for '||global_name||' on Instance='||instance_name||' generated: '||sysdate o  from global_name, v$instance;
set heading on timing off


prompt Configuration: <a href="#Queues in Database"> Queue </a> <a href="#Capture Processes"> Capture </a> <a href="#Propagation"> Propagation </a> <a href="#Apply Processes"> Apply </a> <a href="#Database"> Database </a>

prompt Analysis: <a href="#History"> History </a>  <a href="#Rules"> Rules </a>  <a href="#Notification"> Notifications </a> <a href="#Configuration checks"> Configuration </a> <a href="#Performance Checks"> Performance </a> <a href="#Wait Analysis">  Wait Analysis </a>



prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>



set lines 180
set numf 9999999999999999
set pages 9999
col apply_database_link HEAD 'Database Link|for Remote|Apply' format a15

prompt ============================================================================================
prompt
prompt ++ <a name="Database">DATABASE INFORMATION</a> ++
COL MIN_LOG FORMAT A7
COL PK_LOG FORMAT A6
COL UI_LOG FORMAT A6
COL FK_LOG FORMAT A6
COL ALL_LOG FORMAT A6
COL FORCE_LOG FORMAT A10
col archive_change# format 999999999999999999
col archivelog_change# format 999999999999999999
COL NAME HEADING 'Name'
col platform_name format a30 wrap
col current_scn format 99999999999999999

SELECT DBid,name,created,
SUPPLEMENTAL_LOG_DATA_MIN MIN_LOG,SUPPLEMENTAL_LOG_DATA_PK PK_LOG,
SUPPLEMENTAL_LOG_DATA_UI UI_LOG, 
SUPPLEMENTAL_LOG_DATA_FK FK_LOG,
SUPPLEMENTAL_LOG_DATA_ALL ALL_LOG,
 FORCE_LOGGING FORCE_LOG, 
resetlogs_time,log_mode, archive_change#,
open_mode,database_role,archivelog_change# , current_scn, platform_id, platform_name from v$database;


prompt ============================================================================================
prompt
prompt ++ INSTANCE INFORMATION ++
col host format a20 wrap 
select instance_number INSTANCE, instance_name NAME, HOST_NAME HOST, VERSION,
STARTUP_TIME, STATUS, PARALLEL, ARCHIVER,LOGINS, SHUTDOWN_PENDING, INSTANCE_ROLE, ACTIVE_STATE  from gv$instance;
prompt
prompt ============================================================================================

prompt +++  Current Database Incarnation   +++
prompt

col incarnation# HEADING 'Current|Incarnation' format 9999999999999999
col resetlogs_id HEADING 'ResetLogs|Id'  format 9999999999999999
col resetlogs_change# HEADING 'ResetLogs|Change Number' format 9999999999999999

Select Incarnation#, resetlogs_id,resetlogs_change# from v$database_incarnation where status = 'CURRENT';

prompt ============================================================================================
prompt
prompt ++ REGISTRY INFORMATION ++
col comp_id format a10 wrap
col comp_name format a35 wrap
col version format a10 wrap
col schema format a10

select comp_id, comp_name,version,status,modified,schema from DBA_REGISTRY;

prompt ============================================================================================
prompt
prompt ++ NLS DATABASE PARAMETERS ++
col parameter format a30 wrap
col value format a30 wrap

select * from NLS_DATABASE_PARAMETERS;

prompt ============================================================================================
prompt
prompt ++ GLOBAL NAME ++


select global_name from global_name;

prompt
prompt ============================================================================================
prompt
prompt ++ Key Init.ORA parameters ++
prompt
col name HEADING 'Parameter|Name' format a30
col value HEADING 'Parameter|Value' format a15
col description HEADING 'Description' format a60 word

select name,value,description from v$parameter where name in
   ('aq_tm_processes', 'archive_lag_target', 'job_queue_processes','_job_queue_interval',
    'shared_pool_size', 'sga_max_size', 'sga_target','streams_pool_size',
    'global_names', 'compatible','log_parallelism', 'logmnr_max_persistent_sessions', 
    'parallel_max_servers', 'processes', 'sessions'
    );

prompt
prompt ============================================================================================

prompt 
prompt ++ <a name="Queues in Database">STREAMS QUEUES IN DATABASE</a> ++
prompt ==========================================================================================

prompt
COLUMN OWNER HEADING 'Owner' FORMAT A10
COLUMN NAME HEADING 'Queue Name' FORMAT A30
COLUMN QUEUE_TABLE HEADING 'Queue Table' FORMAT A30
COLUMN ENQUEUE_ENABLED HEADING 'Enqueue|Enabled' FORMAT A7
COLUMN DEQUEUE_ENABLED HEADING 'Dequeue|Enabled' FORMAT A7
COLUMN USER_COMMENT HEADING 'Comment' FORMAT A20
COLUMN PRIMARY_INSTANCE HEADING 'Primary|Instance|Owner'FORMAT 999999
column SECONDARY_INSTANCE HEADING 'Secondary|Instance|Owner' FORMAT 999999
COLUMN OWNER_INSTANCE HEADING 'Owner|Instance' FORMAT 999999
column NETWORK_NAME HEADING 'Network|Name' FORMAT A30

SELECT q.OWNER, q.NAME, t.QUEUE_TABLE, q.enqueue_enabled, 
  q.dequeue_enabled,t.primary_instance,t.secondary_instance, t.owner_instance,network_name, q.USER_COMMENT
  FROM DBA_QUEUES q, DBA_QUEUE_TABLES t
  WHERE t.OBJECT_TYPE = 'SYS.ANYDATA' AND
        q.QUEUE_TABLE = t.QUEUE_TABLE AND
        q.OWNER       = t.OWNER;
prompt

prompt
prompt  +++   Queue Subscribers   ++
prompt

column subscriber HEADING 'Subscriber' format a35 wrap
column name HEADING 'Queue|Name' format a35 wrap
column delivery_mode HEADING 'Delivery|Mode' format a23
column queue_to_queue HEADING 'Queue to|Queue' format a5
column protocol HEADING 'Protocol'
SELECT qs.owner||'.'||qs.queue_name name, qs.queue_table, 
       NVL2(qs.consumer_name,'CONSUMER: ','ADDRESS : ') ||
       NVL(qs.consumer_name,qs.address) Subscriber,
       qs.delivery_mode,qs.queue_to_queue,qs.protocol
FROM dba_queue_subscribers qs, dba_queue_tables qt
WHERE  qt.OBJECT_TYPE = 'SYS.ANYDATA'  AND
       qs.QUEUE_TABLE = qt.QUEUE_TABLE AND
       qs.OWNER = qt.OWNER
ORDER BY qs.owner,qs.queue_name;


prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>

prompt =========================================================================================
prompt
prompt ++ Minimum Archive Log Necessary to Restart Capture ++   
prompt Note:  This query is valid for databases where the capture processes exist for the same source database.
prompt

set serveroutput on
DECLARE
 hScn number := 0;
 lScn number := 0;
 sScn number;
 ascn number;
 alog varchar2(1000);
begin
  select min(start_scn), min(applied_scn) into sScn, ascn
    from dba_capture;


  DBMS_OUTPUT.ENABLE(2000); 

  for cr in (select distinct(a.ckpt_scn)
             from system.logmnr_restart_ckpt$ a
             where a.ckpt_scn <= ascn and a.valid = 1
             and exists (select * from system.logmnr_log$ l
               where a.ckpt_scn between l.first_change# and l.next_change#)
             order by a.ckpt_scn desc)
  loop
    if (hScn = 0) then
       hScn := cr.ckpt_scn;
    else
       lScn := cr.ckpt_scn;
       exit;
    end if;
  end loop;

  if lScn = 0 then
    lScn := sScn;
  end if;

 dbms_output.put_line('Capture will restart from SCN ' || lScn ||' in the following file:');
   for cr in (select name, first_time  
               from DBA_REGISTERED_ARCHIVED_LOG 
               where lScn between first_scn and next_scn order by thread#)
  loop

     dbms_output.put_line(cr.name||' ('||cr.first_time||')');

  end loop;
end;
/


prompt ============================================================================================

prompt
prompt  ++ <a name="Capture Processes">CAPTURE PROCESSES IN DATABASE</a> ++  
-- col start_scn format 9999999999999999
-- col applied_scn format 9999999999999999
col capture_name HEADING 'Capture|Name' format a30 wrap
col status HEADING 'Status' format a10 wrap

col QUEUE HEADING 'Queue' format a25 wrap
col RSN HEADING 'Positive|Rule Set' format a25 wrap
col RSN2 HEADING 'Negative|Rule Set' format a25 wrap
col capture_type HEADING 'Capture|Type' format a10 wrap
col error_message HEADING 'Capture|Error Message' format a60 word
col logfile_assignment HEADING 'Logfile|Assignment'
col checkpoint_retention_time HEADING 'Days to |Retain|Checkpoints'
col Status_change_time HEADING 'Status|Timestamp'
col error_number HEADING 'Error|Number'
col version HEADING 'Version'

SELECT capture_name, queue_owner||'.'||queue_name QUEUE, capture_type, status,
rule_set_owner||'.'||rule_set_name RSN, negative_rule_set_owner||'.'||negative_rule_set_name RSN2, 
checkpoint_retention_time, 
version, logfile_assignment,error_number, status_change_time, error_message 
FROM DBA_CAPTURE;


prompt  ++ CAPTURE PROCESS SOURCE INFORMATION ++  

col QUEUE HEADING 'Queue' format a25 wrap
col RSN HEADING 'Positive|Rule Set' format a25 wrap
col RSN2 HEADING 'Negative|Rule Set' format a25 wrap
col capture_type HEADING 'Capture|Type' format a10 wrap
col source_database HEADING 'Source|Database' format a30 wrap
col first_scn HEADING 'First|SCN'
col start_scn HEADING 'Start|SCN'
col captured_scn HEADING 'Captured|SCN'
col applied_scn HEADING 'Applied|SCN'
col last_enqueued_scn HEADING 'Last|Enqueued|SCN'
col required_checkpoint_scn HEADING 'Required|Checkpoint|SCN'
col max_checkpoint_scn HEADING 'Maximum|Checkpoint|SCN'
col source_dbid HEADING 'Source|Database|ID'
col source_resetlogs_scn HEADING 'Source|ResetLogs|SCN'
col logminer_id HEADING 'Logminer|Session|ID'
col source_resetlogs_time HEADING 'Source|ResetLogs|Time'




SELECT capture_name, capture_type, source_database,  
first_scn, start_scn, captured_scn, applied_scn, last_enqueued_scn,
required_checkpoint_scn,
max_checkpoint_scn, source_dbid, source_resetlogs_scn, 
source_resetlogs_time, logminer_id
FROM DBA_CAPTURE;

prompt
prompt ++ CAPTURE PROCESS PARAMETERS ++
col CAPTURE_NAME  HEADING 'Capture|Name' format a30 wrap
col parameter HEADING 'Parameter|Name' format a25
col value HEADING 'Parameter|Value' format a20
col set_by_user HEADING 'User|Set?'format a5

break on capture_name

select * from dba_capture_parameters order by capture_name,PARAMETER;

prompt ============================================================================================
prompt
prompt ++ STREAMS CAPTURE RULES CONFIGURED WITH DBMS_STREAMS_ADM PACKAGE ++
col NAME Heading 'Capture|Name' format a25 wrap
col object format a45 wrap heading 'Object'

col source_database format a15 wrap
col rule_set_type heading 'Rule Set|Type'
col RULE format a45 wrap  heading 'Rule |Name'
col TYPE format a15 wrap heading 'Rule |Type'
col dml_condition format a40 wrap heading 'Rule|Condition'
col include_tagged_lcr heading 'Tagged|Rules?' format a7

select streams_name NAME,schema_name||'.'||object_name OBJECT, 
rule_set_type,
SOURCE_DATABASE, 
STREAMS_RULE_TYPE ||' '||Rule_type TYPE ,
INCLUDE_TAGGED_LCR,  
rule_owner||'.'||rule_name RULE
from dba_streams_rules where streams_type = 'CAPTURE' 
order by name,object, source_database, rule_set_type,rule;



prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME Heading 'Capture Name' format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap


select streams_name NAME,schema_name||'.'||object_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_rules where streams_type = 'CAPTURE' and (dml_condition is not null or subsetting_operation is not null);

prompt
prompt ++ CAPTURE RULES BY RULE SET ++
col capture_name format a25 wrap  heading 'Capture|Name'
col RULE_SET format a25 wrap heading 'Rule Set|Name'
col RULE_NAME format a25 wrap heading 'Rule|Name'
col condition format a50 wrap heading 'Rule|Condition'
set long 4000 
REM break on rule_set

select c.capture_name, rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
r.rule_condition CONDITION from
dba_rule_set_rules rsr, DBA_RULES r ,DBA_CAPTURE c
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and 
rsr.rule_set_owner=c.rule_set_owner and rsr.rule_set_name=c.rule_set_name  and rsr.rule_set_name in 
(select rule_set_name from dba_capture) order by rsr.rule_set_owner,rsr.rule_set_name;

prompt  +** CAPTURE RULES IN NEGATIVE RULE SET **+
prompt
select c.capture_name, rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
r.rule_condition CONDITION from
dba_rule_set_rules rsr, DBA_RULES r ,DBA_CAPTURE c
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and 
rsr.rule_set_owner=c.negative_rule_set_owner and rsr.rule_set_name=c.negative_rule_set_name 
 and rsr.rule_set_name in 
(select negative_rule_set_name rule_set_name from dba_capture) order by rsr.rule_set_owner,rsr.rule_set_name;

prompt
prompt ++ CAPTURE RULE TRANSFORMATIONS BY RULE SET ++
col RULE_SET format a25 wrap heading 'Rule Set|Name'
col RULE_NAME format a25 wrap heading 'Rule|Name'
col condition format a60 wrap heading 'Rule|Condition'
set long 4000
REM break on RULE_SET

col action_context_name format a32 wrap
col action_context_value format a32 wrap
select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET , r.* from
      dba_rule_set_rules rsr, dba_streams_transformations r
where 
      r.rule_name = rsr.rule_name and r.rule_owner = rsr.rule_owner and rule_set_name in 
      (select rule_set_name from dba_capture) 
order by rsr.rule_set_owner,rsr.rule_set_name, r.rule_owner, r.rule_name,transform_type desc, step_number, precedence;

prompt ============================================================================================
prompt
prompt ++  Registered Log Files for Capture ++

COLUMN CONSUMER_NAME HEADING 'Capture|Process|Name' FORMAT A15
COLUMN SOURCE_DATABASE HEADING 'Source|Database' FORMAT A10
COLUMN SEQUENCE# HEADING 'Sequence|Number' FORMAT 999999
COLUMN NAME HEADING 'Archived Redo Log|File Name' format a35
column first_scn HEADING 'Archived Log|First SCN' 
COLUMN FIRST_TIME HEADING 'Archived Log Begin|Timestamp' 
column next_scn HEADING 'Archived Log|Last SCN' 
COLUMN NEXT_TIME HEADING 'Archived Log Last|Timestamp' 
COLUMN MODIFIED_TIME HEADING 'Archived Log|Registered Time'
COLUMN DICTIONARY_BEGIN HEADING 'Dictionary|Build|Begin' format A6
COLUMN DICTIONARY_END HEADING 'Dictionary|Build|End' format A6
COLUMN PURGEABLE HEADING 'Purgeable|Archive|Log' format a9

SELECT r.CONSUMER_NAME,
       r.SOURCE_DATABASE,
       r.SEQUENCE#, 
       r.NAME, 
       r.first_scn,
       r.FIRST_TIME,
       r.next_scn,
       r.next_time,
       r.MODIFIED_TIME,
       r.DICTIONARY_BEGIN, 
       r.DICTIONARY_END, 
       r.purgeable
  FROM DBA_REGISTERED_ARCHIVED_LOG r, DBA_CAPTURE c
  WHERE r.CONSUMER_NAME = c.CAPTURE_NAME
  ORDER BY source_database, consumer_name, r.first_scn; 

prompt ============================================================================================
prompt
prompt ++  CAPTURE EXTRA ATTRIBUTES ++
 
COLUMN CAPTURE_NAME HEADING 'Capture Process' FORMAT A20
COLUMN ATTRIBUTE_NAME HEADING 'Attribute Name' FORMAT A15
COLUMN INCLUDE HEADING 'Include Attribute in LCRs?' FORMAT A30

SELECT CAPTURE_NAME, ATTRIBUTE_NAME, INCLUDE 
  FROM DBA_CAPTURE_EXTRA_ATTRIBUTES
  ORDER BY CAPTURE_NAME;




prompt ============================================================================================
prompt
prompt ++  TABLES PREPARED FOR CAPTURE ++

col table_owner format a30 HEADING 'Table|Owner'
col table_name format a30 HEADING 'Table|Name'
col timestamp heading 'Timestamp'
col supplemental_log_data_pk HEADING 'PK|Logging'
col supplemental_log_data_ui HEADING 'UI|Logging'
col supplemental_log_data_fk HEADING 'FK|Logging'
col supplemental_log_data_all HEADING 'All|Logging'

select * from dba_capture_prepared_tables order by table_owner,table_name;

prompt ++  SCHEMAS PREPARED FOR CAPTURE ++
col schema_name heading 'Schema|Name'
 
select * from dba_capture_prepared_schemas order by schema_name;

prompt ++ DATABASE PREPARED FOR CAPTURE ++

select * from dba_capture_prepared_database;

prompt ============================================================================================
prompt
prompt ++  TABLES WITH SUPPLEMENTAL LOGGING  ++
col OWNER format a30 wrap
col table_name format a30 wrap

select distinct owner,table_name from dba_log_groups;


prompt
prompt ++  TABLE LEVEL SUPPLEMENTAL LOG GROUPS ENABLED FOR CAPTURE ++
col object format a40 wrap
col column_name format a30 wrap
col log_group_name format a25 wrap

select owner||'.'||table_name OBJECT, log_group_name, log_group_type,
   decode(always,'ALWAYS','Unconditional','CONDITIONAL','Conditional',NULL,'Conditional') ALWAYS, generated from dba_log_groups;

prompt ++ SUPPLEMENTALLY LOGGED COLUMNS ++
col logging_property heading 'Logging|Property' format a9

select owner||'.'||table_name OBJECT, log_group_name, column_name,position,LOGGING_PROPERTY from dba_log_group_columns;



prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>


prompt
prompt ==========================================================================================
prompt
prompt ++ MESSAGING CLIENTS IN DATABASE ++
prompt =========================================================================================
prompt

COLUMN STREAMS_NAME HEADING 'Messaging|Client' FORMAT A25
COLUMN QUEUE_OWNER HEADING 'Queue Owner' FORMAT A10
COLUMN QUEUE_NAME HEADING 'Queue Name' FORMAT A20
COLUMN RULE_SET_NAME HEADING 'Positive|Rule Set' FORMAT A11
COLUMN NEGATIVE_RULE_SET_NAME HEADING 'Negative|Rule Set' FORMAT A11


SELECT STREAMS_NAME, 
       QUEUE_OWNER, 
       QUEUE_NAME, 
       RULE_SET_NAME, 
       NEGATIVE_RULE_SET_NAME 
  FROM DBA_STREAMS_MESSAGE_CONSUMERS
       order by queue_owner, queue_name,streams_name;

prompt
prompt ++ MESSAGE CLIENT NOTIFICATIONS ++
prompt
COLUMN STREAMS_NAME HEADING 'Messaging|Client' FORMAT A25
COLUMN QUEUE_OWNER HEADING 'Queue|Owner' FORMAT A10
COLUMN QUEUE_NAME HEADING 'Queue Name' FORMAT A20
COLUMN NOTIFICATION_TYPE HEADING 'Notification|Type' FORMAT A15
COLUMN NOTIFICATION_ACTION HEADING 'Notification|Action' FORMAT A35

SELECT STREAMS_NAME, 
       QUEUE_OWNER, 
       QUEUE_NAME, 
       NOTIFICATION_TYPE, 
       NOTIFICATION_ACTION 
  FROM DBA_STREAMS_MESSAGE_CONSUMERS    
  WHERE NOTIFICATION_TYPE IS NOT NULL
order by queue_owner,queue_name,streams_name;


prompt
prompt ==========================================================================================
prompt
prompt ++ <a name="Propagation">PROPAGATIONS IN DATABASE</a> ++
prompt =========================================================================================
prompt
COLUMN 'Source Queue' FORMAT A39
COLUMN 'Destination Queue' FORMAT A39
COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A35
column queue_to_queue HEADING 'Q-2-Q'
column error_message HEADING 'Error Message'
column error_date HEADING 'Error Date'

SELECT p.propagation_name, p.SOURCE_QUEUE_OWNER ||'.'|| 
   p.SOURCE_QUEUE_NAME ||'@'|| 
   g.GLOBAL_NAME "Source Queue", 
   p.DESTINATION_QUEUE_OWNER ||'.'|| 
   p.DESTINATION_QUEUE_NAME ||'@'||
   p.DESTINATION_DBLINK "Destination Queue",
   p.queue_to_queue,
   p.status,
   p.error_date,
   p.error_message
   FROM DBA_PROPAGATION p, GLOBAL_NAME g;

prompt
prompt ++ PROPAGATION RULE SETS IN DATABASE ++
prompt
COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A35
COLUMN Positive HEADING 'Positive|Rule Set' FORMAT A35
COLUMN Negative HEADING 'Negative|Rule Set' FORMAT A35

SELECT PROPAGATION_NAME, RULE_SET_OWNER||'.'||RULE_SET_NAME Positive,
  NEGATIVE_RULE_SET_OWNER||'.'||NEGATIVE_RULE_SET_NAME Negative
  FROM DBA_PROPAGATION;

prompt ============================================================================================
prompt
prompt ++ STREAMS PROPAGATION RULES CONFIGURED  ++
col NAME Heading 'Name' format  a25 wrap
col PropNAME format a25 Heading 'Propagation Name'
col object format a25 wrap
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap

select streams_name NAME,schema_name||'.'||object_name OBJECT, 
rule_set_type,
SOURCE_DATABASE, 
STREAMS_RULE_TYPE ||' '||Rule_type TYPE ,
INCLUDE_TAGGED_LCR,  
rule_owner||'.'||rule_name RULE
from dba_streams_rules where streams_type  = 'PROPAGATION' 
order by name,object, source_database, rule_set_type,rule;




prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap


select streams_name NAME,schema_name||'.'||object_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_rules where streams_type = 'PROPAGATION' and (dml_condition is not null or subsetting_operation is not null);

prompt
prompt ++ PROPAGATION  RULES BY RULE SET ++
prompt
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 4000
REM break on RULE_SET

set long 4000
select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
r.rule_condition CONDITION from
dba_rule_set_rules rsr, dba_rules r
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_propagation) order by rsr.rule_set_owner,rsr.rule_set_name;


prompt  +** PROPAGATION RULES IN NEGATIVE RULE SET **+
prompt
select c.propagation_name, rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
r.rule_condition CONDITION from
dba_rule_set_rules rsr, DBA_RULES r ,DBA_PROPAGATION c
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and 
rsr.rule_set_owner=c.negative_rule_set_owner and rsr.rule_set_name=c.negative_rule_set_name 
 and rsr.rule_set_name in 
(select negative_rule_set_name rule_set_name from dba_propagation) order by rsr.rule_set_owner,rsr.rule_set_name;


prompt
prompt ++ PROPAGATION RULE TRANSFORMATIONS BY RULE SET ++
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col action_context_name format a32 wrap
col action_context_value format a32 wrap
REM break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET , r.* from
      dba_rule_set_rules rsr, dba_streams_transformations r
where 
      r.rule_name = rsr.rule_name and r.rule_owner = rsr.rule_owner and rule_set_name in 
      (select rule_set_name from dba_propagation) 
order by rsr.rule_set_owner,rsr.rule_set_name, r.rule_owner, r.rule_name,transform_type desc, step_number, precedence;



prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>

prompt
prompt ============================================================================================

prompt
prompt ++ <a name="Apply Processes">APPLY INFORMATION</a> ++
col apply_name format a25 wrap heading 'Apply|Name'
col queue format a25 wrap heading 'Queue|Name'
col apply_tag format a7 wrap  heading 'Apply|Tag'
col ruleset format a25 wrap heading 'Rule Set|Name'
col apply_user format a15 wrap heading 'Apply|User'
col apply_captured format a15 wrap heading 'Captured or|User Enqueued'
col RSN HEADING 'Positive|Rule Set' format a25 wrap
col RSN2 HEADING 'Negative|Rule Set' format a25 wrap
col apply_database_link HEADING 'Remote Apply|Database Link' format a25 wrap

Select apply_name,queue_owner||'.'||queue_name QUEUE,
DECODE(APPLY_CAPTURED,
                'YES', 'Captured',
                'NO',  'User-Enqueued') APPLY_CAPTURED,status, 
apply_user, apply_tag, rule_set_owner||'.'||rule_set_name RSN,
negative_rule_set_owner||'.'||negative_rule_set_name RSN2, 
apply_database_link from DBA_APPLY;

prompt ++  APPLY PROCESS INFORMATION ++
col max_applied_message_number HEADING 'Maximum Applied|Message Number' 
col error_message HEADING 'Apply|Error Message' format a60 wrap

select apply_name, max_applied_message_number,status, status_change_time,error_number, error_message from dba_apply;


prompt ++  APPLY PROCESS HANDLERS ++

select apply_name, ddl_handler, message_handler, precommit_handler from dba_apply;

prompt
prompt ++ APPLY PROCESS PARAMETERS ++

col APPLY_NAME format a30
col parameter format a20
col value format a20
break on apply_name

select * from dba_apply_parameters order by apply_name,parameter;

prompt ============================================================================================
prompt
prompt ++ STREAMS APPLY RULES CONFIGURED  ++
col NAME format a25 wrap heading 'Streams|Name'
col object format a25 wrap heading 'Database|Object'
col source_database format a15 wrap heading 'Source|Database'
col RULE format a35 wrap heading 'Rule|Name'
col RULE format a35 wrap heading 'Rule|Name'
col TYPE format a15 wrap heading 'Rule|Type'
col dml_condition format a40 wrap heading 'Rule|Condition'


select streams_name NAME,schema_name||'.'||object_name OBJECT, 
rule_set_type,
SOURCE_DATABASE, 
STREAMS_RULE_TYPE ||' '||Rule_type TYPE ,
INCLUDE_TAGGED_LCR,  
rule_owner||'.'||rule_name RULE
from dba_streams_rules where streams_type  = 'APPLY' 
order by name,object, source_database, rule_set_type,rule;

prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap


select streams_name NAME,schema_name||'.'||object_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_rules where streams_type = 'APPLY' and (dml_condition is not null or subsetting_operation is not null);

prompt

prompt ++ APPLY Rules ++
prompt
prompt ++ APPLY RULES BY RULE SET ++
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 4000
REM break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
r.rule_condition CONDITION from
dba_rule_set_rules rsr, dba_rules r
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_apply) order by rsr.rule_set_owner,rsr.rule_set_name;


prompt  +** APPLY RULES IN NEGATIVE RULE SET **+
prompt
select c.apply_name, rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
r.rule_condition CONDITION from
dba_rule_set_rules rsr, DBA_RULES r ,DBA_APPLY c
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and 
rsr.rule_set_owner=c.negative_rule_set_owner and rsr.rule_set_name=c.negative_rule_set_name 
 and rsr.rule_set_name in 
(select negative_rule_set_name rule_set_name from dba_apply) order by rsr.rule_set_owner,rsr.rule_set_name;



prompt
prompt ++ APPLY RULE TRANSFORMATIONS BY RULE SET ++
col action_context_name format a32 wrap
col action_context_value format a32 wrap
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 4000
REM break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET , r.* from
      dba_rule_set_rules rsr, dba_streams_transformations r
where 
      r.rule_name = rsr.rule_name and r.rule_owner = rsr.rule_owner and rule_set_name in 
      (select rule_set_name from dba_apply) 
order by rsr.rule_set_owner,rsr.rule_set_name, r.rule_owner, r.rule_name,transform_type desc, step_number, precedence;


prompt ============================================================================================
prompt
prompt ++ APPLY HANDLERS ++
col apply_name format a25 wrap
col message_handler format a25 wrap
col ddl_handler format a25 wrap

select apply_name, message_handler, ddl_handler from dba_apply where message_handler is not null or ddl_handler is not null;

prompt
prompt ++ APPLY DML HANDLERS ++
col object format a35 wrap
col user_procedure HEADING 'User |Procedure' format a40 wrap
col dblink Heading 'Apply|DBLink' format a15 wrap
col apply_database_link HEAD 'Database Link|for Remote|Apply' format a25 wrap
col operation_name HEADING 'Operation|Name' format a13
col typ  Heading 'Handler|Type' format a5 wrap
col lob_assemble HEADING 'Assemble|Lob?' format a8

select object_owner||'.'||object_name OBJECT, operation_name , 
user_procedure,
apply_name,
decode(error_handler,'Y','Error','N','DML','UNKNOWN') TYP, 
decode(assemble_lobs,'Y','Yes','N','No','UNKNOWN') lob_assemble,
APPLY_Database_link
from dba_apply_dml_handlers 
order by object_owner,object_name,apply_name;

prompt
prompt ++ DML HANDLER STATUS ++
prompt
col user_procedure format a40 wrap

 select o.owner||'.'||o.object_name OBJECT, o.status,o.object_type,o.created, o.last_ddl_time from dba_objects o, 
   (select distinct user_procedure from dba_apply_dml_handlers where user_procedure is not null) h
    where o.owner=replace(substr(h.user_procedure,1,instr(h.user_procedure,'.',1,1)-1),'"',null) 
   and  o.object_name = replace(substr(h.user_procedure,instr(h.user_procedure,'.',-1,1)+1),'"',null);


prompt
prompt ++ RULE TRANSFORMATIONS STATUS ++
col action_context_name format a32 wrap
col action_context_value format a32 wrap head 'Transformation Name'
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 4000
REM break on RULE_SET

select ac.owner||'.'||ac.object_name ACTION_CONTEXT_VALUE,
 o.status, o.object_type, o.created, o.last_ddl_time
from dba_objects o, 
(select distinct replace(substr(transform_function_name,1,instr(transform_function_name,'.',1,1)-1),'"') owner
, replace(substr(transform_function_name,instr(transform_function_name,'.',-1,1)+1),'"') object_name
 from  dba_streams_transform_function ) ac
where o.owner = ac.owner and o.object_name = ac.object_name;


prompt
prompt  ++ APPLY ENQUEUE directives ++

select * from dba_apply_enqueue;

prompt 
prompt ++ APPLY EXECUTE directives ++

select * from dba_apply_execute;

prompt

prompt ++ Conflict Detection Control ++
prompt

select * From dba_apply_table_columns;


prompt ============================================================================================
prompt
prompt ++ UPDATE CONFLICT RESOLUTION COLUMNS ++

col object format a25 wrap
col method_name heading 'Method' format a12
col resolution_column heading 'Resolution|Column' format a13
col column heading 'Column Name' format a30

select object_owner||'.'||object_name object, method_name,
resolution_column, column_name , apply_database_link
from dba_apply_conflict_columns order by object_owner,object_name;


prompt ============================================================================================
prompt
prompt ++ KEY COLUMNS SET FOR APPLY ++

select * from dba_apply_key_columns;

prompt ============================================================================================
prompt
prompt ++ OBJECT DEPENDENCIES SET FOR APPLY ++

select * from dba_apply_object_dependencies;

prompt ============================================================================================
prompt
prompt ++ VALUE DEPENDENCIES SET FOR APPLY ++

select * from dba_apply_value_dependencies;



prompt  ++  APPLY PROGRESS ++
col oldest_message_number HEADING 'Oldest|Message|SCN'
col apply_time HEADING 'Apply|Timestamp'
select * from dba_apply_progress;





prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>



prompt ============================================================================================
prompt
prompt ++  <a name="Errors">ERROR QUEUE</a> ++
col source_commit_scn HEADING 'Source|Commit|Scn'
col message_number HEADING 'Message in| Txn causing|Error'
col message_count HEADING 'Total|Messages|in Txn'
col local_transaction_id HEADING 'Local|Transaction| ID'
col error_message HEADING 'Apply|Error|Message'
col ERROR_CREATION_TIME HEADING 'Error|Creation|Timestamp'
col source_transaction_id HEADING 'Source|Transaction| ID'

Select apply_name, source_database,source_commit_scn,
   message_number, message_count,
   local_transaction_id, 
   error_message , error_creation_time, 
   source_transaction_id
from DBA_APPLY_ERROR order by apply_name ,source_commit_scn ;

prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>
prompt
prompt ============================================================================================
prompt
prompt ++ INSTANTIATION SCNs for APPLY TABLES ++
col source_database format a25 wrap
col object HEADING 'Database|Object' format a45
col instantiation_scn format 9999999999999999
col apply_database_link HEAD 'Database Link|for Remote|Apply' format a25 wrap

select source_database, source_object_owner||'.'||source_object_name OBJECT, 
   ignore_scn,  instantiation_scn, apply_database_link DBLINK 
from dba_apply_instantiated_objects order by source_database, object;

prompt
prompt ++ INSTANTIATION SCNs for APPLY SCHEMA and  DATABASE  (DDL) ++
col OBJECT HEADING 'Database|Object' format a45
col dblink HEADING 'Database|Link'
col inst_scn HEADING 'Instantiation|SCN'
col global_flag HEADING 'Schema or |Database'


select source_db_name source_database, name OBJECT, 
   DBLINK, inst_scn, decode(global_flag,0,'SCHEMA',1,'DATABASE') global_flag
   from sys.apply$_source_schema order by source_database, object;

prompt
prompt ============================================================================================
prompt
prompt ++ DBA OBJECTS - Rules, and Streams Processes ++
prompt
col OBJECT format a45 wrap heading 'Object'

select owner||'.'||object_name OBJECT,
    object_id,object_type,created,last_ddl_time, status from
    dba_objects 
WHERE object_type in ('RULE','RULE SET','CAPTURE','APPLY')
    order by object_type, object;


prompt
prompt ============================================================================================
prompt

prompt ++  Check RECOVERABLE tables populated by MAINTAIN_{TABLE|SCHEMA|GLOBAL} scripts
prompt

set long 100
col progress format a28
select sysdate,rs.creation_time, 
rs.invoking_package||'.'||rs.invoking_procedure PROCEDURE,
rs.status, 
rs.done_block_num||' of '||rs.total_blocks||' Steps Completed' PROGRESS,
to_number(sysdate-rs.creation_time)*86400 ELAPSED_SECONDS,
rs.script_id,
rsb.forward_block CURRENT_STEP
from dba_recoverable_script rs, 
dba_recoverable_script_blocks rsb 
where rs.script_id = rsb.script_id and rsb.block_num = rs.done_block_num + 1;

prompt
prompt  ++ Check RECOVERABLE error ++

SELECT * FROM DBA_RECOVERABLE_SCRIPT_ERRORS;

prompt 
prompt ++ Identify Script Blocks ++

set long 4000
select 
    script_id, block_num, status, 
    forward_block_dblink,forward_block 
  from dba_recoverable_script_blocks order by script_id, block_num;

set long 4000




prompt
prompt ++    <a name="History"> History</a>   ++
prompt

set numf ''

col snap_id format 999999 HEADING 'Snap ID'
col BEGIN_INTERVAL_TIME format a28 HEADING 'Interval|Begin|Time'
col END_INTERVAL_TIME format a28 HEADING 'Interval|End|Time'
col INSTANCE_NUMBER HEADING 'Instance|Number'
col Queue format a28 wrap Heading 'Queue|Name'
col num_msgs    HEADING 'Current|Number of Msgs|in Queue'
col cnum_msgs   HEADING 'Cumulative|Total Msgs|for Queue'
col spill_msgs  HEADING 'Current|Spilled Msgs|in Queue'
col cspill_msgs HEADING 'Cumulative|Total Spilled|for Queue'
col dbid        HEADING 'Database|Identifier'
col total_spilled_msg HEADING 'Cumulative|Total Spilled|Messages'

prompt
prompt ++ Streams Buffered Queue History for last day ++

select s.begin_interval_time,s.end_interval_time , 
   bq.snap_id, 
   bq.num_msgs, bq.spill_msgs, bq.cnum_msgs, bq.cspill_msgs,
   bq.queue_schema||'.'||bq.queue_name Queue,
   bq.queue_id, bq.startup_time,bq.instance_number,bq.dbid
from   dba_hist_buffered_queues bq, dba_hist_snapshot s 
where  bq.snap_id=s.snap_id   and s.end_interval_time >= systimestamp-1 
order by bq.queue_schema,bq.queue_name,s.end_interval_time;


prompt
prompt ++ Streams Buffered Subscriber History for last day ++

select s.begin_interval_time,s.end_interval_time , 
   bs.snap_id,bs.subscriber_id, 
   bs.num_msgs, bs.cnum_msgs, bs.total_spilled_msg,
   bs.subscriber_name,subscriber_address,
   bs.queue_schema||'.'||bs.queue_name Queue,
   bs.startup_time,bs.instance_number,bs.dbid
from   dba_hist_buffered_subscribers bs, dba_hist_snapshot s 
where    bs.snap_id=s.snap_id and s.end_interval_time >= systimestamp-1 
order by    bs.queue_schema,bs.queue_name,bs.subscriber_id,s.end_interval_time;

prompt
prompt ++ Streams Pool Advice History for last day ++

select s.begin_interval_time,s.end_interval_time , 
   pa.snap_id, 
   pa.size_for_estimate, pa.size_factor, pa.estd_spill_count, pa.estd_spill_time,
   pa.estd_unspill_count,pa.estd_unspill_time,
   pa.instance_number,pa.dbid
from   dba_hist_streams_pool_advice pa, dba_hist_snapshot s 
where  pa.snap_id=s.snap_id   and s.end_interval_time >= systimestamp-1 
order by s.end_interval_time, pa.size_factor;


prompt
prompt ++ Streams Capture History for last day ++
column total_messages_created HEADING 'Total|Messages|Created'
column total_messages_enqueued HEADING 'Total Messages|Enqueued'
column lag HEADING 'Capture|Lag|(Seconds)'
column elapsed_capture HEADING 'Elapsed Time|Capture|(centisecs'
column elapsed_rule_time HEADING 'Elapsed Time|Rule Evaluation|(centisecs)'
column elapsed_enqueue_time HEADING 'Elapsed Time|Enqueuing Messages|(centisecs)'
column elapsed_lcr HEADING 'Elapsed Time|LCR Creation|(centisecs)'
column elapsed_redo_wait_time HEADING 'Elapsed Time|Redo Wait|(centisecs)'
column elapsed_Pause_time HEADING 'Elapsed Time|Paused|(centisecs)'



select s.begin_interval_time,s.end_interval_time , 
   sc.capture_name,sc.lag,
   sc.total_messages_captured,sc.total_messages_enqueued,
   sc.elapsed_pause_time,
   sc.elapsed_redo_wait_time, 
   sc.elapsed_rule_time, sc.elapsed_enqueue_time, 
   sc.startup_time,sc.instance_number,sc.dbid
from   dba_hist_streams_capture sc, dba_hist_snapshot s 
where  sc.snap_id=s.snap_id       and s.end_interval_time >= systimestamp-1 
order by sc.capture_name,s.end_interval_time;




prompt
prompt ++ Streams Apply History for last day ++
col reader_total_messages_dequeued HEADING 'Reader|Total Msgs|Dequeued'
col reader_lag HEADING 'Reader|Lag|(Seconds)'
col coord_total_received HEADING 'Coordinator|Total Txn|Received'
col coord_total_applied HEADING 'Coordinator|Total Txn|Applied'
col coord_total_rollbacks HEADING 'Coordinator|Total Txn|Rollbacks'
col coord_total_wait_deps HEADING 'Coordinator|Total Txn|Wait-Dep'
col coord_total_wait_cmts HEADING 'Coordinator|Total Txn|Wait-Cmt'
col coord_lwm_lag HEADING 'Coordinator|LWM Lag|(seconds)'
col server_total_messages_applied HEADING 'Server|Total Msgs|Applied'
col server_elapsed_dequeue_time HEADING 'Server|Elapsed Dequeue|Time (cs)'
col server_elapsed_apply_time HEADING 'Server|Elapsed Apply|Time (cs)'



select s.begin_interval_time,s.end_interval_time , 
   sa.apply_name,sa.reader_lag,  
   sa.reader_total_messages_dequeued,
   sa.coord_lwm_lag,
   sa.coord_total_received,sa.coord_total_applied,
   sa.coord_total_rollbacks,
   sa.coord_total_wait_deps,sa.coord_total_wait_cmts,
   sa.server_total_messages_applied,
   sa.server_elapsed_dequeue_time, 
   sa.server_elapsed_apply_time, 
   sa.startup_time,sa.instance_number,sa.dbid
from    dba_hist_streams_apply_sum sa, dba_hist_snapshot s 
where     sa.snap_id=s.snap_id and s.end_interval_time >= systimestamp-1 
order by sa.apply_name,s.end_interval_time;


prompt
prompt ++    <a name="Rules"> SUSPICIOUS   RULES</a>   ++
prompt
col object format a45 wrap
col rule format a45 wrap


REM  This script does sanity checking of STREAMS objects compared to the underlying RULES.
REM  It is assumed that the DBMS_STREAMS_ADM package procedures
REM     ADD_TABLE_RULES
REM     ADD_SCHEMA_RULES
REM     ADD_GLOBAL_RULES
REM  have been used to configure streams.
prompt
prompt ++ Check for MISSING RULES IN DBA_RULES ++
prompt .  Rows are returned if a rule is defined in DBA_STREAMS_TABLE_RULES (or SCHEMA, GLOBAL, too)
prompt .  but does not exist in the DBA_RULES view.
prompt

select rule_owner,rule_name from dba_streams_rules 
MINUS
select rule_owner,rule_name from dba_rules;

prompt
prompt ++ Check for EXTRA RULES IN DBA_RULES ++
prompt .  Rows are returned if a rule is defined in the DBA_RULES view 
prompt .  but does not exist in the DBA_STREAMS_RULES  view.
prompt
col rule_name format a30

select rule_owner,rule_name from dba_rules 
MINUS 
select rule_owner,rule_name from dba_streams_rules;

prompt
prompt ++ Check for RULE_CONDITIONS DO NOT MATCH BETWEEN STREAMS AND RULES ++
prompt .  Rows are returned if the rule condition is different between the DBA_STREAMS_TABLE_RULES view
prompt .  and the DBA_RULES view.  This indicates that a manual modification has been performed on the 
prompt .  underlying rule.  DBA_STREAMS_TABLE_RULES always shows the initial configuration rule condition. 
prompt

select s.streams_type, s.streams_name, r.rule_owner||'.'||r.rule_name RULE,r.rule_condition 
  from dba_streams_rules s, dba_rules r
  where r.rule_name=s.rule_name and r.rule_owner=s.rule_owner and 
  dbms_lob.substr(s.rule_condition) != dbms_lob.substr(r.rule_condition);

prompt
prompt ++ Check for SOURCE DATABASE NAME DOES NOT MATCH FOR CAPTURE OR PROPAGATION RULES ++

prompt .  Rows are returned if the source database column in the  DBA_STREAMS_ RULES view
prompt .  for capture and/or propagation defined at this site does not match the 
prompt .  global_name of this site.  For capture rules, the source database must match the global_name
prompt .  of database.  For propagation rules, the source database name will typically be the 
prompt .  global name of the database.  In some cases, it may be correct to have a different source
prompt .  database name from the global name.  For example, at an intermediate node between a source site
prompt .  and the ultimate target site OR when using a downstream capture configuration, the rule source database 
prompt .  name field will be diferent from the local.  global name of the intermediate site.
prompt

select streams_type, streams_name, r.rule_owner||'.'||r.rule_name RULE from dba_streams_rules r
where source_database is not null and source_database != (select global_name from global_name) and streams_type in ('CAPTURE','PROPAGATION');

prompt
prompt ++ Check for GLOBAL RULE FOR CAPTURE SPECIFIED BUT CONDITION NOT MODIFIED ++
rem  - It is assumed that GLOBAL rules for CAPTURE  must be modified because of the unsupported datatypes in 9iR2.
prompt .  Rows are returned if a global rule is defined in the  DBA_STREAMS_GLOBAL_RULES view
prompt .  and the rule condition in the DBA_RULES view has not been modified.  
prompt .  In 9iR2, the GLOBAL rule must be modified to eliminate any unsupported datatypes.  For example,
prompt .  the streams administrator schema must be eliminated from the capture rules.  Failure to do 
prompt .  this will result in the abort of the capture process.

select streams_name,  r.rule_owner||'.'||r.rule_name RULE from dba_streams_rules s , dba_rules r
where streams_type = 'CAPTURE' and 
rule_type='GLOBAL' and 
r.rule_name=s.rule_name and 
r.rule_owner=s.rule_owner and 
dbms_lob.substr(s.rule_condition) = dbms_lob.substr(r.rule_condition);

prompt
prompt ++ Check for No RULE SET DEFINED FOR CAPTURE ++
prompt
Prompt    Capture requires a rule set to be defined to assure that only supported datatypes are captured.
prompt

select capture_name, capture_type, source_database from dba_capture where rule_set_name is null and negative_rule_set_name is null;

prompt
prompt ++ Check for APPLY RULES WITH NO SOURCE DATABASE SPECIFIED
prompt .  Rows are returned if no source database is specified in the DBA_STREAMS_TABLE_RULES 
prompt .  (SCHEMA,GLOBAL) view.  An apply process can perform transactions from a single source database.  
prompt .  In a typical replication environment, the source database name must be specified.  In the single
prompt .  site case where captured events from the source database are handled by an apply process on the
prompt .  same database, the source database column does not need to be specified. 
prompt

select streams_name,  s.rule_owner||'.'||s.rule_name RULE, s.schema_name||'.'|| s.object_name OBJECT
from dba_streams_rules s, dba_rules r
where s.streams_type = 'APPLY' and s.source_database is null and
r.rule_name=s.rule_name and
r.rule_owner=s.rule_owner and
dbms_lob.substr(s.rule_condition) = dbms_lob.substr(r.rule_condition);

prompt
prompt ++ Check for SCHEMA RULES FOR NON_EXISTANT SCHEMA ++

select s.streams_type, s.streams_name, s.rule_owner||'.'||s.rule_name RULE, s.schema_name,
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE
from dba_streams_rules s , dba_rules r, dba_users u, table(r.rule_action_context.actx_list) ac
where s.schema_name is null and u.username=s.schema_name 
and r.rule_owner=s.rule_owner and r.rule_name = s.rule_name and ac.nvn_value.accessvarchar2() is null;



prompt
prompt    +++  Fast Evaluation Rule Set Rules for queues +++
prompt
col RULE_SET Heading 'Rule Set' format a25 wrap
col RULE_NAME Heading 'Rule' format a25 wrap
col condition Heading 'Rule Condition' format a60  wrap
set long 4000

 select rsr.rule_set_owner||'.'||rsr.rule_set_name Rule_set,rsr.rule_owner||'.'||rsr.rule_name rule, r.rule_condition 
  from dba_rule_set_rules rsr , dba_rules r
  where rsr.rule_set_name like '%_R' and rsr.rule_name=r.rule_name and rsr.rule_owner=r.rule_owner
  order by rsr.rule_set_owner,rsr.rule_set_name,rsr.rule_owner,rsr.rule_name;


prompt


prompt ++ Check for CONSTRAINTS ON TABLES CONFIGURED IN STREAMS
prompt
col LAST_CHANGE format a11 word heading 'Last|Change'
col search_condition format a25 wrap heading 'Search|Condition'
col ref_constraint HEADING 'Reference|Constraint'

select  c.owner||'.'||c.table_name object,c.constraint_name,c.constraint_type, 
    status, LAST_CHANGE,
    search_condition,r_owner||'.'||r_constraint_name Ref_constraint
   from dba_constraints c,dba_apply_instantiated_objects p where
    c.owner=p.source_object_owner and c.table_name=p.source_object_name and     c.constraint_type in ('P','U','R','C')
    and  constraint_name not like 'SYS_IOT%' order by c.owner,c.table_name;

prompt ++ List INDEXES on TABLES ++
col object format a40 HEADING 'Table'
col index_name format a40
col funcidx_status format a10
col index_type format a10

select table_owner||'.'||table_name object, table_type, index_name,index_type,funcidx_status 
  from dba_indexes i, dba_apply_instantiated_objects p
   where 
         i.owner=p.source_object_owner and i.table_name=p.source_object_name  
         order by i.owner, i.table_name;
 
prompt
prompt ++ List UNSUPPORTED TABLES IN STREAMS
prompt

select * from dba_streams_unsupported;

prompt
prompt ++   STREAMS DICTIONARY INFORMATION ++
prompt    Capture processes defined on system
prompt

col queue format a30 wrap heading 'Queue|Name'
col capture_name format a20 wrap heading 'Capture|Name'
col capture# format 9999 heading 'Capture|Number'
col ruleset format a30 wrap heading 'Positive|Rule Set'
col ruleset2 format a30 wrap heading 'Negative|Rule Set'



select queue_owner||'.'||queue_name queue,capture_name,capture#,
   ruleset_owner||'.'||ruleset_name ruleset,
   negative_ruleset_owner||'.'||negative_ruleset_name ruleset2
   from sys.streams$_capture_process;

prompt
prompt    Apply processes defined on system
prompt
col apply_name format a20 wrap heading 'Apply|Name'
col apply# format 9999 heading 'Apply|Number'

select queue_owner||'.'||queue_name queue,apply_name,apply#,
  ruleset_owner||'.'||ruleset_name  ruleset ,
  negative_ruleset_owner||'.'||negative_ruleset_name  ruleset2 from sys.streams$_apply_process;

prompt
prompt    Propagations defined on system
prompt
col source_queue format a30 wrap heading 'Queue|Name'
col destination format a35 wrap heading 'Destination'

select source_queue_schema||'.'||source_queue source_queue, 
   destination_queue_schema||'.'||destination_queue||'@'||
   destination_dblink destination,
   ruleset_schema||'.'||ruleset ruleset,
   negative_ruleset_schema||'.'||negative_ruleset ruleset2
 from sys.STREAMS$_PROPAGATION_PROCESS;

prompt
prompt    Streams rules defined on system
prompt
col nbr format 9999999999999999 heading 'Number of|Rules'
col streams_name HEADING 'Streams Name' 
col streams_type HEADING 'Streams Type'


select streams_name,streams_type,count(*) nbr From sys.streams$_rules group by streams_name,streams_type;

prompt
prompt ++ 
prompt ++ LOGMINER DATABASE MAP ++
prompt    Databases with information in logminer tables
prompt
col global_name format a30 wrap heading 'Global|Name'
col logmnr_uid format 99999999  heading 'Logminer|Identifier';

select global_name,logmnr_uid,flags,'MAP' SRC from system.logmnrc_dbname_uid_map
union
select s.global_db_name,u.logmnr_uid,null,'UID$' SRC from system.logmnr_uid$ u , system.logmnr_session$ s
    where u.session#=s.session# order by 2;
select * from system.logmnr_uid$;
select * from system.logmnr_session$;

prompt
prompt ++  LOGMINER STATISTICS
prompt 
select c.capture_name, name, value from gv$streams_capture c, gv$logmnr_stats l
 where c.logminer_id = l.session_id 
   order by capture_name,name;  


prompt ++  LOGMINER SESSION STATISTICS
prompt 
select * from  gv$logmnr_session 
   order by session_name;  

prompt
prompt ++ LOGMINER CACHE OBJECTS ++
prompt     Objects of interest to Streams from each source database
prompt
col count(*) format 9999999999999999  heading 'Number of|Interesting|DB Objects';

select logmnr_uid, count(*) from system.logmnrc_gtlo group by logmnr_uid;

prompt
prompt     Intcol Verification
prompt  

select logmnr_uid, obj#, objv#, intcol#
      from system.logmnrc_gtcs
      group by logmnr_uid, obj#, objv#, intcol#
      having count(1) > 1
      order by 1,2,3,4;

prompt
prompt     Segcol Verification  
prompt  Check bug 7033630 if rows returned

select a.logmnr_uid,a.obj#,a.objv#,a.segcol#, a.intcol# from system.logmnrc_gtcs a
   where exists ( select 1 from system.logmnrc_gtcs b where
                           a.logmnr_uid = b.logmnr_uid and
                           a.obj# = b.obj# and
                           a.objv# = b.objv# and
                           a.segcol# = b.segcol# and
                           a.segcol# <> 0 and
                           a.intcol# <> b.intcol#);
prompt
prompt  ++ LCR Cache Information ++
prompt    Internal LCRs
select * from x$kngfl;
prompt
prompt    External LCRs
select * from x$kngfle;
prompt


prompt
prompt  ++ Streams Pool memory Information ++
prompt
select * from x$knlasg;
prompt

prompt
prompt  ++ Queue Memory and Flow Control Values ++
select * from x$kwqbpmt;

prompt 
Prompt   ++ JOBS in Database ++
prompt
set recsep each
set recsepchar =
select * from dba_jobs;

set recsep off

prompt ++ DBA_QUEUE_SCHEDULES ++
prompt
select * from dba_queue_schedules 
order by schema,qname,destination,message_delivery_mode;
prompt

prompt
prompt ++ Agents ++
prompt
select * from dba_aq_agents;
prompt


prompt
prompt ++ Agent Privileges ++
prompt
select * from dba_aq_agent_privs;


prompt
prompt  ++  Current Long Running Transactions ++  
prompt   Current transactions open for more than 20 minutes
prompt
col runlength HEAD 'Txn Open|Minutes' format 9999.99
col sid HEAD 'Session' format a13
col xid HEAD 'Transaction|ID' format a18
col terminal HEAD 'Terminal' format a10
col program HEAD 'Program' format a27 wrap

select t.inst_id, sid||','||serial# sid,xidusn||'.'||xidslot||'.'||xidsqn xid, 
(sysdate -  start_date ) * 1440 runlength ,terminal,program from gv$transaction t, gv$session s 
where t.addr=s.taddr and (sysdate - start_date) * 1440 > 20;

prompt
prompt    ++   Streams Pool Advice   ++
prompt
col streams_pool_size_factor format 999.99 HEADING 'Stream Pool Size|Factor'
col streams_pool_size_for_estimate HEADING 'Stream Pool Size|Estimate'
col estd_spill_count  HEADING 'Spill Count|Estimated'
col estd_spill_time   HEADING 'Spill Time |Estimated'
col estd_unspill_count  HEADING 'UnSpill Count|Estimated'
col estd_unspill_time   HEADING 'UnSpill Time |Estimated'

select streams_pool_size_factor,streams_pool_size_for_estimate,
       estd_spill_count, estd_spill_time,
       estd_unspill_count, estd_unspill_time      
from v$streams_pool_advice;


prompt ++  STREAMS ALERTS History (10.2.0.3+)
prompt
prompt  +++ Most recent Streams alerts(max=10) occuring within last 10 days +++
prompt
column Instance Heading 'Instance Name|(Instance Number)'
select message_Type,creation_time, reason,suggested_action,
       module_id,object_type,                    host_id,
       instance_name||'   ( '||instance_number||' )' Instance,      
       resolution,time_suggested
from dba_alert_history where message_group ='Streams' 
      and creation_time >= sysdate -10 and rownum < 11
order by creation_time desc;
prompt
prompt
REM prompt  ++  Current Contents of the STREAMS Pool ++  
REM prompt   Applies only to versions 10.1.0.4+, and to this instance only
REM prompt

REM col comm HEAD 'Allocation Comment' format A18
REM col alloc_size HEAD 'Bytes Allocated' format 9999999999999999
REM select ksmchcom comm, sum(ksmchsiz) alloc_size from x$ksmsst group by ksmchcom order by 2 desc;

prompt
prompt   ++ init.ora parameters ++
Prompt  Key parameters are aq_tm_processes, job_queue_processes
prompt                     streams_pool_size, sga_max_size, global_name, compatible
prompt                     

show parameters

set serveroutput on 
prompt  +++  <a name="Statistics"> STREAMS STATISTICS</a>  +++
prompt
alter session set nls_date_format='HH24:Mi:SS MM/DD/YY';
set heading off 
select 'STREAMS Health Check (V3.0.26) for '||global_name||' on Instance='||instance_name||' generated: '||sysdate o  from global_name, v$instance;
set heading on

prompt =========================================================================================
prompt
prompt ++ <a name="Queue Statistics">MESSAGES IN BUFFER QUEUE</a> ++
col QUEUE format a50 wrap
col "Message Count" format 9999999999999999 heading 'Current Number of|Outstanding|Messages|in Queue'
col "Spilled Msgs" format 9999999999999999 heading 'Current Number of|Spilled|Messages|in Queue'
col "TOtal Messages" format 9999999999999999 heading 'Cumulative |Number| of Messages|in Queue'
col "Total Spilled Msgs" format 9999999999999999 heading 'Cumulative Number|of Spilled|Messages|in Queue'
col "Expired_Msgs" heading 'Current Number of|Expired|Messages|in Queue'


SELECT queue_schema||'.'||queue_name Queue, startup_time, num_msgs "Message Count", spill_msgs "Spilled Msgs", cnum_msgs "Total Messages", cspill_msgs "Total Spilled Msgs", expired_msgs  FROM  gv$buffered_queues;

prompt Configuration: <a href="#Queues in Database"> Queue </a> <a href="#Capture Processes"> Capture </a> <a href="#Propagation"> Propagation </a> <a href="#Apply Processes"> Apply </a> <a href="#Database"> Database </a>

prompt Analysis: <a href="#History"> History </a>  <a href="#Rules"> Rules </a>  <a href="#Notification"> Notifications </a> <a href="#Configuration checks"> Configuration </a> <a href="#Performance Checks"> Performance </a> <a href="#Wait Analysis">  Wait Analysis </a>

prompt ============================================================================================
prompt
prompt ++ <a name="Capture Statistics">CAPTURE STATISTICS</a> ++
COLUMN PROCESS_NAME HEADING "Capture|Process|Number" FORMAT A7
COLUMN CAPTURE_NAME HEADING 'Capture|Name' FORMAT A10
COLUMN SID HEADING 'Session|ID' FORMAT 99999999999999
COLUMN SERIAL# HEADING 'Session|Serial|Number' 
COLUMN STATE HEADING 'State' FORMAT A17
column STATE_CHANGED_TIME HEADING 'Last|State Change|Time'
COLUMN TOTAL_MESSAGES_CAPTURED HEADING 'Redo Entries|Scanned'  
COLUMN TOTAL_MESSAGES_ENQUEUED HEADING 'Total|LCRs|Enqueued'  
COLUMN TOTAL_MESSAGES_CREATED HEADING 'Total|Messages|Created'  

COLUMN LATENCY_SECONDS HEADING 'Latency|Seconds' FORMAT 9999999999999999
COLUMN CREATE_TIME HEADING 'Event Creation|Time' FORMAT A19
COLUMN ENQUEUE_TIME HEADING 'Last|Enqueue |Time' FORMAT A19
COLUMN ENQUEUE_MESSAGE_NUMBER HEADING 'Last Queued|Message Number' FORMAT 9999999999999999
COLUMN ENQUEUE_MESSAGE_CREATE_TIME HEADING 'Last Queued|Message|Create Time'FORMAT A19
COLUMN CAPTURE_MESSAGE_CREATE_TIME HEADING 'Last Redo|Message|Create Time' FORMAT A19
COLUMN CAPTURE_MESSAGE_NUMBER HEADING 'Last Redo|Message Number' FORMAT 9999999999999999
COLUMN AVAILABLE_MESSAGE_CREATE_TIME HEADING 'Available|Message|Create Time' FORMAT A19
COLUMN AVAILABLE_MESSAGE_NUMBER HEADING 'Available|Message Number' FORMAT 9999999999999999
COLUMN STARTUP_TIME HEADING 'Startup Timestamp' FORMAT A19

COLUMN MSG_STATE HEADING 'Message State' FORMAT A13
COLUMN CONSUMER_NAME HEADING 'Consumer' FORMAT A30

COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A8
COLUMN START_DATE HEADING 'Start Date'
COLUMN PROPAGATION_WINDOW HEADING 'Duration' FORMAT 99999
COLUMN NEXT_TIME HEADING 'Next|Time' FORMAT A8
COLUMN LATENCY HEADING 'Latency|Seconds' FORMAT 99999999


-- ALTER session set nls_date_format='HH24:MI:SS MM/DD/YY';

SELECT SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       c.CAPTURE_NAME,
       C.STARTUP_TIME,
       c.SID,
       c.SERIAL#,
       c.STATE,
       c.state_changed_time,
       c.TOTAL_MESSAGES_CAPTURED,
       c.TOTAL_MESSAGES_ENQUEUED, total_messages_created
  FROM gV$STREAMS_CAPTURE c, gV$SESSION s
  WHERE c.SID = s.SID AND
        c.SERIAL# = s.SERIAL#;

SELECT capture_name, 
   SYSDATE "Current Time",
   capture_time "Capture Process TS",
   capture_message_number,
   capture_message_create_time ,
   enqueue_time ,
   enqueue_message_number,
   enqueue_message_create_time ,
   available_message_number,
   available_message_create_time    
FROM gV$STREAMS_CAPTURE;

COLUMN processed_scn HEADING 'Logminer Last|Processed Message' FORMAT 9999999999999999
COLUMN AVAILABLE_MESSAGE_NUMBER HEADING 'Last Message|Written to Redo' FORMAT 9999999999999999
SELECT c.capture_name, l.processed_scn, c.available_message_number
FROM gV$LOGMNR_SESSION l, gv$STREAMS_CAPTURE c
WHERE c.logminer_id = l.session_id;

COLUMN CAPTURE_NAME HEADING 'Capture|Name' FORMAT A15
COLUMN TOTAL_PREFILTER_DISCARDED HEADING 'Prefilter|Events|Discarded' FORMAT 9999999999999999
COLUMN TOTAL_PREFILTER_KEPT HEADING 'Prefilter|Events|Kept' FORMAT 9999999999999999
COLUMN TOTAL_PREFILTER_EVALUATIONS HEADING 'Prefilter|Evaluations' FORMAT 9999999999999999
COLUMN UNDECIDED HEADING 'Undecided|After|Prefilter' FORMAT 9999999999999999
COLUMN TOTAL_FULL_EVALUATIONS HEADING 'Full|Evaluations' FORMAT 9999999999999999

SELECT CAPTURE_NAME,
       TOTAL_PREFILTER_DISCARDED,
       TOTAL_PREFILTER_KEPT,
       TOTAL_PREFILTER_EVALUATIONS,
       (TOTAL_PREFILTER_EVALUATIONS - 
         (TOTAL_PREFILTER_KEPT + TOTAL_PREFILTER_DISCARDED)) UNDECIDED,
       TOTAL_FULL_EVALUATIONS
  FROM gV$STREAMS_CAPTURE;

column elapsed_capture HEADING 'Elapsed Time|Capture|(centisecs)'
column elapsed_rule HEADING 'Elapsed Time|Rule Evaluation|(centisecs)'
column elapsed_enqueue HEADING 'Elapsed Time|Enqueuing Messages|(centisecs)'
column elapsed_lcr HEADING 'Elapsed Time|LCR Creation|(centisecs)'
column elapsed_redo HEADING 'Elapsed Time|Redo Wait|(centisecs)'
column elapsed_Pause HEADING 'Elapsed Time|Paused|(centisecs)'

SELECT CAPTURE_NAME, ELAPSED_CAPTURE_TIME elapsed_capture,  
       elapsed_rule_time elapsed_rule,        
       ELAPSED_ENQUEUE_TIME 
       elapsed_enqueue, 
       ELAPSED_LCR_TIME elapsed_lcr,
       ELAPSED_REDO_WAIT_TIME elapsed_redo, 
       ELAPSED_PAUSE_TIME elapsed_pause,       
       total_messages_created,    total_messages_enqueued,     total_full_evaluations 
  from gv$streams_capture;


prompt
prompt ++ LOGMINER STATISTICS ++
prompt ++ (pageouts imply logminer spill) ++
COLUMN CAPTURE_NAME HEADING 'Capture|Name' FORMAT A32
COLUMN NAME HEADING 'Statistic' FORMAT A32
COLUMN VALUE HEADING 'Value' FORMAT 9999999999999999

select c.capture_name, name, value from gv$streams_capture c, gv$logmnr_stats l
 where c.logminer_id = l.session_id 
   and name in ('bytes paged out', 'microsecs spent in pageout', 
                'bytes of redo processed', 'bytes checkpointed',
                'seconds spent in checkpoint',
                'resume from low memory',
                'DDL txns mined', 'CTAS txns mined' ,'rolled back txns mined',
                'DDL txns delivered', 'DML txns delivered','CTAS txns delivered',
                'recursive txns delivered');  

prompt
prompt ++ BUFFERED PUBLISHERS ++
select * from gv$buffered_publishers;




prompt ============================================================================================
prompt
prompt ++ OPEN STREAMS CAPTURE TRANSACTIONS ++
prompt
prompt +**   Count    **+
select streams_name, count(*) "Open Transactions",sum(cumulative_message_count) "Total LCRs" from gv$streams_transaction where streams_type='CAPTURE' group by streams_name;
prompt
prompt +**   Detail    **+
select * from gv$streams_transaction where streams_type='CAPTURE' order by streams_name,first_message_number;

prompt Configuration: <a href="#Queues in Database"> Queue </a> <a href="#Capture Processes"> Capture </a> <a href="#Propagation"> Propagation </a> <a href="#Apply Processes"> Apply </a> <a href="#Database"> Database </a>

prompt Analysis: <a href="#History"> History </a>  <a href="#Rules"> Rules </a>  <a href="#Notification"> Notifications </a> <a href="#Configuration checks"> Configuration </a> <a href="#Performance Checks"> Performance </a> <a href="#Wait Analysis">  Wait Analysis </a>
prompt Statistics Quick Link: <a href="#Queue Statistics">Queue</a> <a href="#Capture Statistics">Capture</a>  <a href="#Propagation Statistics">Propagation</a> <a href="#Apply Statistics">Apply</a> <a href="#Errors"> Errors</a>

prompt =========================================================================================
prompt
prompt ++ <a name="Propagation Statistics">SCHEDULE FOR EACH PROPAGATION</a>++
prompt =========================================================================================
prompt
COLUMN PROPAGATION_NAME Heading 'Propagation|Name' format a17 wrap
COLUMN START_DATE HEADING 'Start Date'
COLUMN PROPAGATION_WINDOW HEADING 'Duration|in Seconds' FORMAT 9999999999999999
COLUMN NEXT_TIME HEADING 'Next|Time' FORMAT A8
COLUMN LATENCY HEADING 'Latency|in Seconds' FORMAT 9999999999999999
COLUMN SCHEDULE_DISABLED HEADING 'Status' FORMAT A8
COLUMN PROCESS_NAME HEADING 'Process' FORMAT A8
COLUMN FAILURES HEADING 'Number of|Failures' FORMAT 99
COLUMN LAST_ERROR_MSG HEADING 'Error Message' FORMAT A50 
COLUMN TOTAL_BYTES HEADING 'Total Bytes|Propagated' FORMAT 9999999999999999
COLUMN CURRENT_START_DATE HEADING 'Current|Start' FORMAT A17
COLUMN LAST_RUN_DATE HEADING 'Last|Run' FORMAT A17
COLUMN NEXT_RUN_DATE HEADING 'Next|Run' FORMAT A17
COLUMN LAST_ERROR_DATE HEADING 'Last|Error' FORMAT A17
column message_delivery_mode HEADING 'Message|Delivery|Mode'
column queue_to_queue HEADING 'Q-2-Q'

SELECT p.propagation_name,TO_CHAR(s.START_DATE, 'HH24:MI:SS MM/DD/YY') START_DATE,
       s.PROPAGATION_WINDOW, 
       s.NEXT_TIME, 
       s.LATENCY,
       DECODE(s.SCHEDULE_DISABLED,
                'Y', 'Disabled',
                'N', 'Enabled') SCHEDULE_DISABLED,
       s.PROCESS_NAME, s.total_bytes,
       s.FAILURES,
       s.message_delivery_mode,
       p.queue_to_queue,
       s.LAST_ERROR_MSG      
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
    WHERE   p.DESTINATION_DBLINK = 
        NVL(REGEXP_SUBSTR(s.destination, '[^@]+', 1, 2), s.destination)
  AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND s.QNAME = p.SOURCE_QUEUE_NAME order by message_delivery_mode, propagation_name;

SELECT p.propagation_name, message_delivery_mode, TO_CHAR(s.LAST_RUN_DATE, 'HH24:MI:SS MM/DD/YY') LAST_RUN_DATE,
   TO_CHAR(s.CURRENT_START_DATE, 'HH24:MI:SS MM/DD/YY') CURRENT_START_DATE, 
   TO_CHAR(s.NEXT_RUN_DATE, 'HH24:MI:SS MM/DD/YY') NEXT_RUN_DATE, 
   TO_CHAR(s.LAST_ERROR_DATE, 'HH24:MI:SS MM/DD/YY') LAST_ERROR_DATE
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
    WHERE   p.DESTINATION_DBLINK = 
        NVL(REGEXP_SUBSTR(s.destination, '[^@]+', 1, 2), s.destination)
  AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND s.QNAME = p.SOURCE_QUEUE_NAME order by message_delivery_mode, propagation_name;

prompt
prompt ++ EVENTS AND BYTES PROPAGATED FOR EACH PROPAGATION++
prompt
COLUMN Elapsed_propagation_TIME HEADING 'Elapsed |Propagation Time|(Seconds)' FORMAT 9999999999999999
COLUMN TOTAL_NUMBER HEADING 'Total |Events|Propagated' FORMAT 9999999999999999
COLUMN TOTAL_BYTES HEADING 'Total Bytes|Propagated' FORMAT 9999999999999999
COLUMN SCHEDULE_STATUS HEADING 'Schedule|Status'
column elapsed_dequeue_time HEADING 'Elapsed|Dequeue Time|(Seconds)'
column elapsed_pickle_time HEADING 'Total Time|(Seconds)'
column total_time HEADING 'Elapsed|Pickle Time|(Seconds)'
column high_water_mark HEADING 'High|Water|Mark'
column acknowledgement HEADING 'Target |Ack'


SELECT p.propagation_name,q.message_delivery_mode, DECODE(p.STATUS,
                'DISABLED', 'Disabled',
                'ENABLED', 'Enabled') SCHEDULE_STATUS,
  q.instance,
  q.total_number TOTAL_NUMBER, q.TOTAL_BYTES ,
  q.elapsed_dequeue_time/100 elapsed_dequeue_time, q.elapsed_pickle_time/100 elapsed_pickle_time,
  q.total_time/100 total_time
  FROM  DBA_PROPAGATION p, dba_queue_schedules q
      WHERE   p.DESTINATION_DBLINK = 
        NVL(REGEXP_SUBSTR(q.destination, '[^@]+', 1, 2), q.destination)
  AND q.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND q.QNAME = p.SOURCE_QUEUE_NAME 
  order by q.message_delivery_mode, p.propagation_name;



prompt ++ PROPAGATION SENDER STATISTICS ++
prompt
col queue_id HEADING 'Queue ID'
col queue_schema HEADING 'Source|Queue|Owner'
col queue_name HEADING 'Source|Queue|Name'
col dst_queue_schema HEADING 'Destination|Queue|Owner'
col dst_queue_name HEADING 'Destination|Queue|Name'
col dblink Heading 'Destination|Database|Link'
col total_msgs HEADING 'Total|Messages'
col max_num_per_win HEADING 'Max Msgs|per|Window'
col max_size HEADING 'Max|Size'
col src_queue_schema HEADING 'Source|Queue|Owner'
col src_queue_name HEADING 'Source|Queue|Name'
column elapsed_dequeue_time HEADING 'Elapsed|Dequeue Time|(CentiSecs)'
column elapsed_pickle_time HEADING 'Total Time|(CentiSecs)'
column total_time HEADING 'Elapsed|Pickle Time|(CentiSecs)'


SELECT * from v$propagation_sender;

prompt Statistics Quick Link: <a href="#Queue Statistics">Queue</a> <a href="#Capture Statistics">Capture</a>  <a href="#Propagation Statistics">Propagation</a> <a href="#Apply Statistics">Apply</a> <a href="#Errors"> Errors</a>

prompt
prompt ++ PROPAGATION RECEIVER STATISTICS++
prompt

column src_queue_name HEADING 'Source|Queue|Name'
column src_dbname HEADING 'Source|Database|Name'
column startup_time HEADING 'Startup|Time'
column elapsed_unpickle_time HEADING 'Elapsed|Unpickle Time|(CentiSeconds'
column elapsed_rule_time HEADING 'Elapsed|Rule Time|(CentiSeconds)'
column elapsed_enqueue_time HEADING 'Elapsed|Enqueue Time|(CentiSeconds)'

SELECT * from gv$propagation_receiver;

prompt
prompt ++ BUFFERED SUBSCRIBERS ++

select * from gv$buffered_subscribers;

prompt Configuration: <a href="#Queues in Database"> Queue </a> <a href="#Capture Processes"> Capture </a> <a href="#Propagation"> Propagation </a> <a href="#Apply Processes"> Apply </a> <a href="#Database"> Database </a>

prompt Analysis: <a href="#History"> History </a>  <a href="#Rules"> Rules </a> <a href="#Notification"> Notifications </a> <a href="#Configuration checks"> Configuration </a> <a href="#Performance Checks"> Performance </a> <a href="#Wait Analysis">  Wait Analysis </a>

prompt Statistics Quick Link: <a href="#Queue Statistics">Queue</a> <a href="#Capture Statistics">Capture</a>  <a href="#Propagation Statistics">Propagation</a> <a href="#Apply Statistics">Apply</a> <a href="#Errors"> Errors</a>

prompt ============================================================================================
prompt
prompt ++ <a name="Apply Statistics">APPLY STATISTICS</a> ++
prompt
prompt ============================================================================================



prompt
prompt ++ APPLY Reader Statistics ++
col oldest_scn_num HEADING 'Oldest|SCN'
col apply_name HEADING 'Apply Name'
col apply_captured HEADING 'Captured or|User-Enqueued LCRs'
col process_name HEADING 'Process'
col state HEADING 'STATE'
col total_messages_dequeued HEADING 'Total Messages|Dequeued'
col total_messages_spilled Heading 'Total Messages|Spilled'
col sga_used HEADING 'SGA Used'
col oldest_transaction_id HEADING 'Oldest|Transaction'

SELECT ap.APPLY_NAME,
       DECODE(ap.APPLY_CAPTURED,
                'YES','Captured LCRS',
                'NO','User-Enqueued','UNKNOWN') APPLY_CAPTURED,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       r.STATE,
       r.TOTAL_MESSAGES_DEQUEUED,
       r.TOTAL_MESSAGES_SPILLED,
       r.SGA_USED, 
       oldest_scn_num,
       oldest_xidusn||'.'||oldest_xidslt||'.'||oldest_xidsqn 
             oldest_transaction_id
       FROM gV$STREAMS_APPLY_READER r, gV$SESSION s, DBA_APPLY ap
       WHERE r.SID = s.SID AND
             r.SERIAL# = s.SERIAL# AND
             r.APPLY_NAME = ap.APPLY_NAME;

col creation HEADING 'Dequeued Message|Creation|Timestamp'
col last_dequeue HEADING 'Dequeue |Timestamp'
col dequeued_message_number HEADING 'Last |Dequeued Message|Number'
col last_browse_num HEADING 'Last|Browsed Message|Number'
col latency HEADING 'Apply Reader|Latency|(Seconds)'

SELECT APPLY_NAME,
       (DEQUEUE_TIME-DEQUEUED_MESSAGE_CREATE_TIME)*86400 LATENCY,
     TO_CHAR(DEQUEUED_MESSAGE_CREATE_TIME,'HH24:MI:SS MM/DD') CREATION,
     TO_CHAR(DEQUEUE_TIME,'HH24:MI:SS MM/DD') LAST_DEQUEUE, 
     DEQUEUED_MESSAGE_NUMBER,
     last_browse_num
  FROM gV$STREAMS_APPLY_READER;

col elapsed_dequeue HEADING 'Elapsed Time|Dequeue|(centisecs)'
col elapsed_schedule HEADING 'Elapsed Time|Schedule|(centisecs)'
col elapsed_spill HEADING 'Elapsed Time|Spill|(centisecs)'
col elapsed_idle HEADING 'Elapsed Time|Idle|(centisecs)'

Select APPLY_NAME, total_messages_dequeued, total_messages_spilled,         Elapsed_dequeue_time Elapsed_dequeue, 
        elapsed_schedule_time elapsed_schedule, 
        elapsed_spill_time elapsed_spill
  from gv$STREAMS_APPLY_READER;

prompt ============================================================================================
prompt
prompt ++ APPLY SPILLED TRANSACTIONS ++

col APPLY_NAME	Head 'Apply Name'
col txn_id   HEAD 'Transaction|ID'
col  FIRST_SCN	Head 'SCN of First| Message in Txn'
col  MESSAGE_COUNT  Head 'Count of |Messages in Txn'
col  FIRST_MESSAGE_CREATE_TIME	Head 'First Message|Creation Time'
col  SPILL_CREATION_TIME  Head ' Spill |Creation Time'

select Apply_name, 
       xidusn||'.'||xidslt||'.'||xidsqn txn_id,
       first_scn, 
       first_message_create_time, 
       message_count, 
       spill_creation_time   
    from dba_apply_SPILL_TXN;


prompt ============================================================================================
prompt
prompt ++ APPLY Coordinator Statistics ++
col apply_name HEADING 'Apply Name' format a22 wrap
col process HEADING 'Process' format a7
col RECEIVED HEADING 'Total|Txns|Received' 
col ASSIGNED HEADING 'Total|Txns|Assigned' 
col APPLIED HEADING 'Total|Txns|Applied' 
col ERRORS HEADING 'Total|Txns|w/ Error' 
col total_ignored HEADING 'Total|Txns|Ignored' 
col total_rollbacks HEADING 'Total|Txns|Rollback' 
col WAIT_DEPS HEADING 'Total|Txns|Wait_Deps' 
col WAIT_COMMITS HEADING 'Total|Txns|Wait_Commits' 
col STATE HEADING 'State' format a10 word

SELECT ap.APPLY_NAME,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS,
       c.STATE,
       c.TOTAL_RECEIVED RECEIVED,
       c.TOTAL_ASSIGNED ASSIGNED,
       c.TOTAL_APPLIED APPLIED,
       c.TOTAL_ERRORS ERRORS,
       c.total_ignored,
       c.total_rollbacks,
       c.TOTAL_WAIT_DEPS WAIT_DEPS, c.TOTAL_WAIT_COMMITS WAIT_COMMITS
       FROM gV$STREAMS_APPLY_COORDINATOR  c, gV$SESSION s, DBA_APPLY ap
       WHERE c.SID = s.SID AND
             c.SERIAL# = s.SERIAL# AND
             c.APPLY_NAME = ap.APPLY_NAME;

col lwm_msg_ts HEADING 'LWM Message|Creation|Timestamp'
col lwm_msg_nbr HEADING 'LWM Message|SCN'
col lwm_updated HEADING 'LWM Updated|Timestamp'
col hwm_msg_ts HEADING 'HWM Message|Creation|Timestamp'
col hwm_msg_nbr HEADING 'HWM Message|SCN'
col hwm_updated HEADING 'HWM Updated|Timestamp'


SELECT APPLY_NAME,
     LWM_MESSAGE_CREATE_TIME LWM_MSG_TS ,
     LWM_MESSAGE_NUMBER LWM_MSG_NBR ,
     LWM_TIME LWM_UPDATED,
     HWM_MESSAGE_CREATE_TIME HWM_MSG_TS,
     HWM_MESSAGE_NUMBER HWM_MSG_NBR ,
     HWM_TIME HWM_UPDATED
  FROM gV$STREAMS_APPLY_COORDINATOR;

SELECT APPLY_NAME,      TOTAL_RECEIVED,TOTAL_ASSIGNED,TOTAL_APPLIED,
     STARTUP_TIME,
     ELAPSED_SCHEDULE_TIME elapsed_schedule, 
     ELAPSED_IDLE_TIME  elapsed_idle
from gv$streams_apply_coordinator;
     
prompt ============================================================================================
prompt
prompt  ++ APPLY Server Statistics ++
col SRVR format 9999
col ASSIGNED format 9999999999999999 Heading 'Total|Transactions|Assigned'
col MSG_APPLIED heading 'Total|Messages|Applied' FORMAT 9999999999999999
col MESSAGE_SEQUENCE FORMAT 9999999999999999
col applied_message_create_time HEADING 'Applied Message|Creation|Timestamp'
col applied_message_number HEADING 'Last Applied|Message|SCN'
col lwm_updated HEADING 'Applied|Timestamp'
col message_sequence HEADING 'Message|Sequence'
col elapsed_apply_time HEADING 'Elapsed|Apply|Time (cs)'
col elapsed_dequeue_time HEADING 'Elapsed|Dequeue|Time (cs)'
col apply_time Heading 'Apply Time'

SELECT ap.APPLY_NAME,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       a.server_id SRVR,
       a.STATE,
       a.TOTAL_ASSIGNED ASSIGNED,
       a.TOTAL_MESSAGES_APPLIED msg_APPLIED,
       a.APPLIED_MESSAGE_NUMBER, 
       a.APPLIED_MESSAGE_CREATE_TIME ,
       a.MESSAGE_SEQUENCE, a.elapsed_dequeue_time, a.elapsed_apply_time, a.apply_time
       FROM gV$STREAMS_APPLY_SERVER a, gV$SESSION s, DBA_APPLY ap
       WHERE a.SID = s.SID AND
             a.SERIAL# = s.SERIAL# AND
             a.APPLY_NAME = ap.APPLY_NAME order by a.apply_name, a.server_id;


Col apply_name Heading 'Apply Name' FORMAT A30
Col server_id Heading 'Apply Server Number' FORMAT 99999999
Col sqltext Heading 'Current SQL' FORMAT A64

select a.inst_id, a.apply_name,  a.server_id, q.sql_text sqltext
  from gv$streams_apply_server a, gv$sqltext q, gv$session s
 where a.sid = s.sid and s.sql_hash_value = q.hash_value 
   and s.sql_address = q.address and s.sql_id = q.sql_id 
 order by a.apply_name, a.server_id, q.piece;

Col apply_name Heading 'Apply Name' FORMAT A30
Col server_id Heading 'Apply Server Number' FORMAT 99999999
Col event Heading 'Wait Event' FORMAT A64
Col secs Heading 'Seconds Waiting' FORMAT 9999999999999999

select a.inst_id, a.apply_name, a.server_id, w.event, w.seconds_in_wait secs
  from gv$streams_apply_server a, gv$session_wait w 
 where a.sid = w.sid order by a.apply_name, a.server_id;

Col apply_name Heading 'Apply Name' FORMAT A30
Col server_id Heading 'Apply Server Number' FORMAT 99999999
Col event Heading 'Wait Event' FORMAT 99999999
Col total_waits Heading 'Total Waits' FORMAT 9999999999999999
Col total_timeouts Heading 'Total Timeouts' FORMAT 9999999999999999
Col time_waited Heading 'Time Waited' FORMAT 9999999999999999
Col average_wait Heading 'Average Wait' FORMAT 9999999999999999
Col max_wait Heading 'Maximum Wait' FORMAT 9999999999999999

select a.inst_id, a.apply_name, a.server_id, e.event, e.total_waits, e.total_timeouts,
       e.time_waited, e.average_wait, e.max_wait 
  from gv$streams_apply_server a, gv$session_event e
 where a.sid = e.sid order by a.apply_name, a.server_id,e.time_waited desc;

prompt Statistics: <a href="#Statistics"> Streams Statistics </a> <a href="#Queue Statistics"> Queue </a> <a href="#Capture Statistics"> Capture </a> <a href="#Propagation Statistics"> Propagation </a> <a href="#Apply Statistics"> Apply </a> <a href="#Errors"> Apply_Errors </a>

col current_txn format a15 wrap
col dependent_txn format a15 wrap

select APPLY_NAME, server_id SRVR,
xidusn||'.'||xidslt||'.'||xidsqn CURRENT_TXN,
commitscn,
dep_xidusn||'.'||dep_xidslt||'.'||dep_xidsqn DEPENDENT_TXN,
dep_commitscn
from  gv$streams_apply_server order by apply_name,server_id;


prompt  ++  APPLY PROGRESS ++
col oldest_message_number HEADING 'Oldest|Message|SCN'
col apply_time HEADING 'Apply|Timestamp'
select * from dba_apply_progress;

prompt ============================================================================================
prompt
prompt ++ OPEN STREAMS APPLY TRANSACTIONS ++
prompt
prompt +**   Count    **+
select streams_name, count(*) "Open Transactions",sum(cumulative_message_count) "Total LCRs" from gv$streams_transaction where streams_type='APPLY' group by streams_name;

prompt
prompt +**   Detail    **+
select * from gv$streams_transaction where streams_type='APPLY' order by streams_name,first_message_number;
prompt



prompt Configuration: <a href="#Queues in Database"> Queue </a> <a href="#Capture Processes"> Capture </a> <a href="#Propagation"> Propagation </a> <a href="#Apply Processes"> Apply </a> <a href="#Database"> Database </a>

prompt Analysis: <a href="#History"> History </a>  <a href="#Rules"> Rules </a> <a href="#Notification"> Notifications </a> <a href="#Configuration checks"> Configuration </a> <a href="#Performance Checks"> Performance </a> <a href="#Wait Analysis">  Wait Analysis </a>

prompt Statistics Quick Link: <a href="#Queue Statistics">Queue</a> <a href="#Capture Statistics">Capture</a>  <a href="#Propagation Statistics">Propagation</a> <a href="#Apply Statistics">Apply</a> <a href="#Errors"> Errors</a>


prompt
prompt ++   STATISTICS on RULES and RULE SETS
prompt ++
prompt ++   RULE SET STATISTICS
prompt

col name HEADING 'Name'

select * from gv$rule_set;


prompt
prompt ++  RULE STATISTICS
prompt

select * from gv$rule;

prompt


-- note:  this function is vulnerable to SQL injection, please do not copy it
create or replace function get_parameter(
  param_name        IN varchar2,
  param_value       IN OUT varchar2,
  table_name        IN varchar2,
  table_param_name  IN varchar2,
  table_value       IN varchar2
) return boolean is
  statement varchar2(4000);
begin
  -- construct query 
  statement :=  'select ' || table_value || ' from ' || table_name || ' where ' 
                || table_param_name || '=''' || param_name || '''';

  begin
    execute immediate statement into param_value;
  exception when no_data_found then
    -- data is not found, so return FALSE
    return FALSE;
  end;
  -- data found, so return TRUE
  return TRUE;
end get_parameter;
/
show errors;

create or replace procedure verify_init_parameter( 
  param_name         IN varchar2, 
  expected_value     IN varchar2,
  verbose            IN boolean,
  more_info          IN varchar2 := NULL,
  more_info2         IN varchar2 := NULL,
  at_least           IN boolean := FALSE,
  is_error           IN boolean := FALSE,
  use_like           IN boolean := FALSE,
  -- may not be necessary
  alert_if_not_found IN boolean := TRUE
) 
is
  current_val_num  NUMBER;
  expected_val_num NUMBER;
  current_value    varchar2(512);
  prefix           varchar2(20);
  matches          boolean := FALSE;
  comparison_str   varchar2(20);
begin
  -- Set prefix as warning or error
  if is_error then
    prefix := '+  ERROR:  ';
  else
    prefix := '+  WARNING:  ';
  end if;

  -- Set comparison string
  if at_least then
    comparison_str := ' at least ';
  elsif use_like then
    comparison_str := ' like ';
  else
    comparison_str := ' set to ';
  end if;

  -- Get value
  if get_parameter(param_name, current_value, 'v$parameter', 'name', 'value') = FALSE 
     and alert_if_not_found then
    -- Value isn't set, so output alert
    dbms_output.put_line(prefix || 'The parameter ''' || param_name || ''' should be'
                         || comparison_str || '''' || expected_value 
                         || ''', instead it has been left to its default value.'); 
    if verbose and more_info is not null then
      dbms_output.put_line(more_info);
      if more_info2 is not null then
        dbms_output.put_line(more_info2);
      end if;
    end if;
    dbms_output.put_line('+');
    return;
  end if;

  -- See if the expected value is what is actually set
  if use_like then
    -- Compare with 'like'
    if current_value like '%'||expected_value||'%' then
      matches := TRUE;
    end if;
  elsif at_least then
    -- Do at least
    current_val_num := to_number(current_value);
    expected_val_num := to_number(expected_value);
    if current_val_num >= expected_val_num then
      matches := TRUE;
    end if;
  else
    -- Do normal comparison
    if current_value = expected_value then
      matches := TRUE;
    end if;
  end if;
  
  if matches = FALSE then
    -- The values don't match, so alert
    dbms_output.put_line(prefix || 'The parameter ''' || param_name || ''' should be'
                         || comparison_str || '''' || expected_value 
                         || ''', instead it has the value ''' || current_value || '''.'); 
    if verbose and more_info is not null then
      dbms_output.put_line(more_info);
      if more_info2 is not null then
        dbms_output.put_line(more_info2);
      end if;
    end if;
    dbms_output.put_line('+');
  end if;

end verify_init_parameter;
/
show errors;

prompt
prompt ============================================================================================
prompt ==================================== Summary ===============================================
prompt ============================================================================================

prompt
prompt
prompt  ++
prompt  ++ <a name="Notification">Notifications</a> ++
prompt  ++
prompt

set serveroutput on size 50000
declare
  -- Change the variable below to FALSE if you just want the warnings and errors, not the advice
  verbose                      boolean := TRUE;
  -- By default any errors in dba_apply_error will result in output
  apply_error_threshold        number := 0;          
  -- By default a streams pool usage above 95% will result in output
  streams_pool_usage_threshold number := 95;  
  -- The total number of registered archive logs to have before reporting an error
  registered_logs_threshold    number := 1000;
  -- The total number of days old the oldest archived log should be before reporting an error
  registered_age_threshold     number := 60;  -- days

  row_count number;
  days_old number;
  failed boolean;
  streams_pool_usage number;
  streams_pool_size varchar2(512);

  cursor apply_error is select distinct apply_name from dba_apply_error;
  cursor aborted_apply is 
    select apply_name, error_number, error_message from dba_apply where status='ABORTED';
  cursor aborted_capture is 
    select capture_name, error_number, error_message from dba_capture where status='ABORTED';
  cursor aborted_prop is 
    select propagation_name, last_error_date, last_error_msg from dba_propagation, dba_queue_schedules 
    where  schema = source_queue_owner and qname = source_queue_name and destination = destination_dblink 
    and schedule_disabled = 'Y' and message_delivery_mode = 'BUFFERED';
  cursor disabled_apply is select apply_name from dba_apply where status='DISABLED';
  cursor disabled_capture is select capture_name from dba_capture where status='DISABLED';

  
begin
  -- Check for aborted capture processes
  for rec in aborted_capture loop
    dbms_output.put_line('+  ERROR:  Capture ''' || rec.capture_name || ''' has aborted with message ' || 
                         rec.error_message);
  end loop;

  dbms_output.put_line('+');

  -- Check for aborted apply processes
  for rec in aborted_apply loop
    dbms_output.put_line('+  ERROR:  Apply ''' || rec.apply_name || ''' has aborted with message ' || 
                         rec.error_message);
    if verbose then
      -- Try to give some suggestions
      -- TODO:  include other errors, suggest how to recover
      if rec.error_number = 26714 then
        dbms_output.put_line('+    This apply aborted because a non-fatal user error has occurred and the ''disable_on_error'' parameter is ''Y''.');
        dbms_output.put_line('+    Please resolve the errors and restart the apply.  Setting the ''disable_on_error'' parameter to ''N'' will prevent');
        dbms_output.put_line('+    apply from aborting on user errors in the future.  Note the errors should still be resolved though.');
        dbms_output.put_line('+');
      elsif rec.error_number = 26688 then
        dbms_output.put_line('+    This apply aborted because a column value in a particular change record belonging to a key was not found.  ');
        dbms_output.put_line('+    For more information, search the trace files for ''26688'' and view the relevant trace file.');
        dbms_output.put_line('+');
      end if;
    end if;
  end loop;

  dbms_output.put_line('+');

  -- Check for apply errors in the error queue
  for rec in apply_error loop
    select count(*) into row_count from dba_apply_error where rec.apply_name = apply_name;
    if row_count > apply_error_threshold then
      dbms_output.put_line('+  ERROR:  Apply ''' || rec.apply_name || ''' has placed ' || 
                           row_count || ' transactions in the error queue!  Please check the dba_apply_error view.');
    end if;
  end loop;

  dbms_output.put_line('+');

  -- Check for aborted propagation
  for rec in aborted_prop loop
    dbms_output.put_line('+  ERROR:  Propagation ''' || rec.propagation_name 
                         || ''' has aborted with most recent error message:');
    dbms_output.put_line('+    ''' || rec.last_error_msg || '''');
    dbms_output.put_line('+');
  end loop;

  -- Check for disabled capture processes
  for rec in disabled_capture loop
    dbms_output.put_line('+  WARNING:  Capture ''' || rec.capture_name || ''' is disabled');
  end loop;

  dbms_output.put_line('+');

  -- Check for disabled apply processes
  for rec in disabled_apply loop
    dbms_output.put_line('+  WARNING:  Apply ''' || rec.apply_name || ''' is disabled');
  end loop;

  dbms_output.put_line('+');

 

  -- Check for too many registered archive logs
  begin
    failed := FALSE;
    select count(*) into row_count from dba_registered_archived_log where purgeable = 'NO';
    select (sysdate - min(modified_time)) into days_old from dba_registered_archived_log where purgeable = 'NO';
    if row_count > registered_logs_threshold then 
      failed := TRUE;
      dbms_output.put_line('+  WARNING:  ' || row_count || ' archived logs registered.');
    end if;
    if days_old > registered_age_threshold then
      failed := TRUE;
      dbms_output.put_line('+  WARNING:  The oldest archived log is ' || round(days_old) || ' days old!');
    end if;
    select count(*) into row_count from dba_registered_archived_log where purgeable = 'YES';
    if row_count > registered_logs_threshold/2 then
      dbms_output.put_line('+  WARNING:  There are '|| row_count ||' archived logs ready to be purged from disk.');
      dbms_output.put_line('+          Use the following select to identify unneeded logfiles:');
      dbms_output.put_line('+          select name from dba_registered_archived_log where purgeable = "YES"  ');
    end if;
    
    if failed then
      dbms_output.put_line('+    A restarting Capture process must mine through each registered archive log.');
      dbms_output.put_line('+    To speedup Capture restart, reduce the amount of disk space taken by the archived');
      dbms_output.put_line('+    logs, and reduce Capture metadata, consider moving the first_scn automatically by  ');
      dbms_output.put_line('+    altering the checkpoint_retention_time capture parameter to a lower value ');
      dbms_output.put_line('+    (See the Documentation for more information).  ');
      dbms_output.put_line('+    Note that once the first scn is increased, Capture will no longer be able to mine before');
      dbms_output.put_line('+    this new scn value.');
      dbms_output.put_line('+    Successive moves of the first_scn will remove unneeded registered archive');
      dbms_output.put_line('+    logs only if the files have been removed from disk');
    end if;
  end;
end;
/
prompt
prompt  ++
prompt  ++  SYS Checks
prompt  ++
prompt
declare
  -- Change the variable below to FALSE if you just want the warnings and errors, not the advice
  verbose                      boolean := TRUE;
    -- By default a streams pool usage above 95% will result in output
  streams_pool_usage_threshold number := 95;  
  
  row_count number;
  days_old number;
  failed boolean;
  streams_pool_usage number;
  streams_pool_size varchar2(512);

     cursor unrecovered_queue is select queue_schema,queue_name from x$buffered_queues where flags=1;

begin
 -- Check high streams pool usage
  begin 
    select FRUSED_KWQBPMT into streams_pool_usage from x$kwqbpmt;
    select value into streams_pool_size from v$parameter where name = 'streams_pool_size';
    if streams_pool_usage > streams_pool_usage_threshold then
      dbms_output.put_line('+  WARNING:  Streams pool usage for this instance is ' || streams_pool_usage ||
                           '% of ' || streams_pool_size || ' bytes!');
      dbms_output.put_line('+    If this system is processing a typical workload, and no ' ||
                           'other errors exist, consider increasing the streams pool size.');
    end if;
  exception when others then null;
  end;


  dbms_output.put_line('+');

-- Check unrecovered queues
  
    for rec in unrecovered_queue loop
    dbms_output.put_line('+  ERROR: Queue ''' || rec.queue_schema || '.'||rec.queue_name||' has not been recovered normally ' );
    dbms_output.put_line('+         Force recovery by altering the queue ownership to another instance. ');
    dbms_output.put_line('+         Use the DBMS_AQADM.ALTER_QUEUE_TABLE procedure to specify a different instance.');
  end loop;

  dbms_output.put_line('+');

end;
/


prompt
prompt  ++
prompt  ++ init.ora checks ++
prompt  ++
declare
  -- Change the variable below to FALSE if you just want the warnings and errors, not the advice
  verbose            boolean := TRUE;
  row_count          number;
  num_downstream_cap number;
  capture_procs      number;
  apply_procs        number;
  newline            varchar2(1) := '
';
begin
  -- Error checks first
  verify_init_parameter('global_names', 'TRUE', verbose, is_error=>TRUE);
  verify_init_parameter('job_queue_processes', '4', verbose, at_least=> TRUE, is_error=>TRUE);
  verify_init_parameter('open_links', '4', verbose, at_least=> TRUE, is_error=>TRUE, alert_if_not_found=>FALSE);
  -- Get minimum number of parallel_max_servers to set
  select NVL(sum(to_number(value)+2), 0) into capture_procs from dba_capture_parameters where parameter = 'PARALLELISM';
  select NVL(sum(to_number(value)+2), 0) into apply_procs from dba_apply_parameters where parameter = 'PARALLELISM';
  
  verify_init_parameter('parallel_max_servers', to_char(capture_procs + apply_procs), verbose, 
                        '+    If you have stray Capture or Apply processes on the system, you can ignore this error.',
                        at_least=> TRUE, is_error=>TRUE);

  -- Do downstream capture checks
  select count(*) into num_downstream_cap from dba_capture where capture_type = 'DOWNSTREAM';
  if num_downstream_cap > 0 then
    -- We have a downstream capture, so do specific checks
    verify_init_parameter('remote_archive_enable', 'TRUE', verbose, is_error=>TRUE);
  end if;

  -- Then warnings
  verify_init_parameter('_job_queue_interval', '1', verbose, 
                        '+    This parameter when set properly will allow propagation ' ||
                        'processes to send messages more frequently.');
  verify_init_parameter('compatible', '10.2.0', verbose, 
                        '+    To use the new Streams features introduced in Oracle Database 10g Release 2, '||  
                        'this parameter must be set to a value greater than ''10.2.0''',
                        use_like => TRUE);


-- explictly check if aq_tm_processes has been manually set to 0.  If so, raise error.
 declare
   mycheck number;
 begin
   select 1 into mycheck from v$parameter where name = 'aq_tm_processes' and value = '0'
     and (ismodified <> 'FALSE' OR isdefault='FALSE');
   if mycheck = 1 then
     dbms_output.put_line('+  ERROR:  The parameter ''aq_tm_processes'' should not be explicitly set to 0!');
     dbms_output.put_line('+          Queue monitoring is disabled for all queues.');
     dbms_output.put_line('+    To resolve this problem, set the value to 1 using:  ALTER SYSTEM SET AQ_TM_PROCESSES=1;  ');
   end if;
   exception when no_data_found then null;
 end;

-- explictly check if aq_tm_processes has been manually set to 10.  If so, raise error.
 declare
   mycheck number;
 begin
   select 1 into mycheck from v$parameter where name = 'aq_tm_processes' and isdefault = 'FALSE'
     and value = '10';
   if mycheck = 1 then
     dbms_output.put_line('+  ERROR:  The parameter ''aq_tm_processes'' should not be explicitly set to 10!');
     dbms_output.put_line('+          With this setting, queue monitoring is disabled for buffered queues.');
     dbms_output.put_line('+    To resolve this problem, set the value to 1 using:  ALTER SYSTEM SET AQ_TM_PROCESSES=1;  ');
   end if;
   exception when no_data_found then null;
 end;

  verify_init_parameter('streams_pool_size', '0', TRUE, 
                        '+    If this parameter is 0 and sga_target is non-zero, then autotuning of the streams pool is implied.'||newline||
                        '+    If the sga_target parameter is set to 0 and streams_pool_size is 0,'|| newline||
                        '+    10% of the shared pool will be used for Streams.' || newline ||
                        '+    If sga_target is 0, the minimum recommendation for streams_pool_size is 200M.'|| newline||
                        '+      Note you must bounce the database if changing the ',
                        '+    value from zero to a nonzero value.  But if simply increasing this' || newline ||
                        '+    value from an already nonzero value, the database need not be bounced.',
                        at_least=> TRUE);
end;
/

prompt
prompt  ++
prompt  ++ <a name="Configuration checks">Configuration checks</a> ++
prompt  ++
declare
  current_value varchar2(4000);

  cursor propagation_latency is
  select propagation_name, latency from dba_propagation, dba_queue_schedules 
   where schema = source_queue_owner and qname = source_queue_name and destination = destination_dblink 
     and latency >= 60  and message_delivery_mode = 'BUFFERED';
  cursor multiqueues is
   select c.capture_name capture_name, a.apply_name apply_name, 
          c.queue_owner queue_owner, c.queue_name queue_name
     from dba_capture c, dba_apply a
    where c.queue_name = a.queue_name and c.queue_owner = a.queue_owner
      and c.capture_type != 'DOWNSTREAM';

  cursor nonlogged_tables is 
    select table_owner owner,table_name name from dba_capture_prepared_tables t 
     where supplemental_log_data_pk='NO' and supplemental_log_data_fk='NO' and supplemental_log_data_ui='NO' and
      supplemental_log_data_all='NO' 
     and not exists (
         select 'X' from dba_log_groups l where t.table_owner = l.owner and t.table_name = l.table_name
           UNION
         select 'x' from dba_capture_prepared_schemas s where s.schema_name =t.table_owner 
           UNION 
         select 'x' from dba_capture_prepared_database);



  cursor overlapping_rules is
   select a.streams_name sname, a.streams_type stype, 
          a.rule_set_owner rule_set_owner, a.rule_set_name rule_set_name, 
          a.rule_owner owner1, a.rule_name name1, a.streams_rule_type type1, 
          b.rule_owner owner2, b.rule_name name2, b.streams_rule_type type2
     from dba_streams_rules a, dba_streams_rules b
    where a.rule_set_owner = b.rule_set_owner 
      and a.rule_set_name = b.rule_set_name
      and a.streams_name = b.streams_name and a.streams_type = b.streams_type
      and a.rule_type = b.rule_type
      and (a.subsetting_operation is null or b.subsetting_operation is null)
      and (a.rule_owner != b.rule_owner or a.rule_name != b.rule_name)
      and ((a.streams_rule_type = 'GLOBAL' and b.streams_rule_type 
            in ('SCHEMA', 'TABLE') and a.schema_name = b.schema_name)
       or (a.streams_rule_type = 'SCHEMA' and b.streams_rule_type = 'TABLE' 
           and a.schema_name = b.schema_name)
       or (a.streams_rule_type = 'TABLE' and b.streams_rule_type = 'TABLE' 
           and a.schema_name = b.schema_name and a.object_name = b.object_name
           and a.rule_name < b.rule_name)
       or (a.streams_rule_type = 'SCHEMA' and b.streams_rule_type = 'SCHEMA' 
           and a.schema_name = b.schema_name and a.rule_name < b.rule_name)
       or (a.streams_rule_type = 'GLOBAL' and b.streams_rule_type = 'GLOBAL' 
           and a.rule_name < b.rule_name))
       order by a.rule_name;
  cursor spilled_apply is
  select a.apply_name
    from dba_apply_parameters p, dba_apply a, gv$buffered_queues q
   where a.queue_owner = q.queue_schema and a.queue_name = q.queue_name
     and a.apply_name = p.apply_name and p.parameter = 'PARALLELISM' 
     and p.value > 1 and (q.cspill_msgs/DECODE(q.cnum_msgs, 0, 1, q.cnum_msgs) * 100) > 25;

  cursor bad_source_db is
   select rule_owner||'.'||rule_name Rule_name, source_database from dba_streams_rules where source_database not in 
             (select global_name from system.logmnrc_dbname_uid_map);


  cursor qtab_too_long is
     select queue_table name, length(queue_table) len from dba_queues q , dba_apply a where 
        length(queue_table)>24 and q.owner=a.queue_owner and q.name=a.queue_name;

  cursor reginfo_invalid is
     select comp_id,status from dba_registry where comp_id in ('CATALOG','CATPROC') and status <> 'VALID';

  cursor version_diff is
     select i.version inst_version,r.version reg_version from v$instance i, dba_registry r where 
        r.comp_id  in ('CATALOG','CATPROC') and i.version <> r.version;

  row_count     number;
  capture_count number;
  verbose       boolean := TRUE;
  overlap_rules boolean := FALSE;
  latency       number;
begin
  -- Check that propagation latency is not 60
  for rec in propagation_latency loop
    dbms_output.put_line('+  WARNING:  the Propagation process ''' || rec.propagation_name ||
                         ''' has latency ' || rec.latency || ', it should be 5 or less!');
    if verbose then 
      dbms_output.put_line('+    Set the latency by calling ' ||
                           'dbms_aqadm.alter_schedule(queue_name,destination,latency=>5)');
    end if;
    dbms_output.put_line('+');
  end loop;

  -- Check source database names on rules
  for rec in bad_source_db loop
     dbms_output.put_line('+  ERROR:  The rule '||rec.rule_name||' specifies an unknown source database: '||rec.source_database||'.');
  end loop;

  -- Check queue table name length
  for rec in qtab_too_long loop
     dbms_output.put_line('+  ERROR:  The queue table name '''||rec.name||''' has length of '||rec.len||
                          ' bytes, it should be 24 bytes or less!');
     dbms_output.put_line('+');
  end loop;
        
  -- Check  Registry Info STATUS
  for rec in reginfo_invalid loop
     dbms_output.put_line('+  ERROR:  The DBA_REGISTRY status information for component '''||rec.comp_id||
      ''' requires attention.  Status is '||rec.status||
                          '. Please recompile the component ');
     dbms_output.put_line('+');
  end loop;                

  -- Check consistent Instance and Registry Info
  for rec in version_diff loop
     dbms_output.put_line('+  ERROR:  The ORACLE_HOME software is '''||rec.inst_version||''' but the database catalog is '||rec.reg_version||
                          '.  CATPATCH must be run successfully to complete the upgrade');
     dbms_output.put_line('+');
  end loop;                


  -- Separate queues for capture and apply
  for rec in multiqueues loop
    dbms_output.put_line('+  WARNING:  the Capture process ''' || rec.capture_name ||
                         ''' and Apply process ''' || rec.apply_name || '''');
    dbms_output.put_line('+    share the same queue ''' || rec.queue_owner || '.' 
                         || rec.queue_name || '''.  If the Apply process is receiving changes');
    dbms_output.put_line('+    from a remote site, a separate queue should be created for'
                         || ' the Apply process.');
  end loop;

  dbms_output.put_line('+');

  -- Make sure it is in archivelog mode
  select count(*) into capture_count from dba_capture where capture_type != 'DOWNSTREAM';
  select count(*) into row_count from v$database where log_mode = 'NOARCHIVELOG';
  if row_count > 0 and capture_count > 0 then
    dbms_output.put_line('+  ERROR:  ARCHIVELOG mode must be enabled for this database.');
    if verbose then
      dbms_output.put_line('+    For a Streams Capture process to function correctly, it'
                           || ' must be able to read the archive logs.');
      dbms_output.put_line('+    Please refer to the documentation to restart the database'
                           || ' in ARCHIVELOG format.');
      dbms_output.put_line('+');
    end if;
  end if;

  -- Basic supplemental logging checks
  -- #1.  If minimal supplemental logging is not enabled, this is an error
  select count(*) into row_count from v$database where SUPPLEMENTAL_LOG_DATA_MIN = 'NO';
  if row_count > 0 and capture_count > 0 then
    dbms_output.put_line('+  ERROR:  Minimal supplemental logging not enabled.');
    if verbose then 
      dbms_output.put_line('+    For a Streams Capture process to function correctly, at'
                           || ' least minimal supplemental logging should be enabled.');
      dbms_output.put_line('+    Execute ''ALTER DATABASE ADD SUPPLEMENTAL LOG DATA'''
                           || ' to fix this issue.  Note you may need to specify further');
      dbms_output.put_line('+    levels of supplemental logging, see the documentation'
                           || ' for more details.');
      dbms_output.put_line('+');
    end if;
  end if;

  -- #2.  If Primary key database level logging not enabled, there better be some 
  -- log data per prepared table
  select count(*) into row_count from v$database where SUPPLEMENTAL_LOG_DATA_PK = 'NO';
  if row_count > 0 and capture_count > 0 then
    for rec in nonlogged_tables loop
      dbms_output.put_line('+  ERROR:  No supplemental logging specified for table '''
                           || rec.owner || '.' || rec.name || '''.');
      if verbose then 
        dbms_output.put_line('+    In order for Streams to work properly, it must' ||
                             ' have key information supplementally logged');
        dbms_output.put_line('+    for each table whose changes are being captured.  ' ||
                             'This system does not have database level primary key information ');
        dbms_output.put_line('logged, thus for each interested table manual logging '
                             || 'must be specified.  Please see the documentation for more info.');
        dbms_output.put_line('+');
      end if;
    end loop;
  end if;

  -- Rules checks
  -- TODO:  intergrate existing rules checks found above     
  for rec in overlapping_rules loop
    overlap_rules := TRUE;
    dbms_output.put_line('+  WARNING:  The rule ''' || rec.owner1 || '''.''' || rec.name1 
                         || ''' and ''' || rec.owner2 || '''.''' || rec.name2 
                         || ''' from rule set ''' || rec.rule_set_owner || '''.''' 
                         || rec.rule_set_name || ''' overlap.');
  end loop;

  if overlap_rules and verbose then
    dbms_output.put_line('+    Overlapping rules are a problem especially when rule-based transformations exist.');
    dbms_output.put_line('+    Streams makes no guarantees of which rule in a rule set will evaluate to TRUE,');
    dbms_output.put_line('+    thus overlapping rules will cause inconsistent behavior, and should be avoided.');
  end if;
  dbms_output.put_line('+');

  --
  -- Suggestions.  These might help speedup performance.
  --

  if verbose then 
    -- Propagation has a rule set
    select count(*) into row_count from dba_propagation where rule_set_owner is not null 
       and rule_set_name is not null;
    if row_count > 0 then 
      dbms_output.put_line('+  SUGGESTION:  One or more propagation processes contain rule sets.');
      dbms_output.put_line('+    If a Propagation process will unconditionally forward all incoming');
      dbms_output.put_line('+    messages to its destination queue, and no rule-based transformations are');
      dbms_output.put_line('+    performed by the Propagation process, you should consider removing');
      dbms_output.put_line('+    the rule set for the Propagation process via dbms_propagation_adm.alter_propagation.');
      dbms_output.put_line('+    This will improve Propagation performance.');
      dbms_output.put_line('+');
    end if;

    -- Apply has a rule set
    select count(*) into row_count from dba_apply where rule_set_owner is not null 
       and rule_set_name is not null;
    if row_count > 0 then 
      dbms_output.put_line('+  SUGGESTION:  One or more apply processes contain rule sets.');
      dbms_output.put_line('+    If an Apply process will unconditionally apply all incoming');
      dbms_output.put_line('+    messages and no rule-based transformations or apply enqueues are ');
      dbms_output.put_line('+    performed by the Apply process, you should consider removing  ');
      dbms_output.put_line('+    the rule set for via dbms_apply_adm.alter_apply.');
      dbms_output.put_line('+    This will improve Apply performance.');
      dbms_output.put_line('+');
    end if;
  
    -- Apply has parallelism 1
    select count(*) into row_count from dba_apply_parameters where parameter='PARALLELISM' 
       and to_number(value) = 1;
    if row_count > 0 then 
      dbms_output.put_line('+  SUGGESTION:  One or more Apply processes have parallelism 1');
      dbms_output.put_line('+    If your workload consists of many independent transactions');
      dbms_output.put_line('+    and you notice that apply is the bottleneck of your system, ');
      dbms_output.put_line('+    you might consider increasing the parallelism of the apply process');
      dbms_output.put_line('+    to a multiple of 4 via dbms_apply_adm.set_parameter.');
      dbms_output.put_line('+');
    end if;

    -- If apply parallelism > 1, and spills exist in queue, and _txn_buffer_size
    -- hasn't been set, suggest reducing it to 10 or less. 
    for rec in spilled_apply loop
      begin
        select value into current_value from dba_apply_parameters where parameter='_TXN_BUFFER_SIZE' 
           and apply_name = rec.apply_name;
      exception when no_data_found then
        -- default parameter, output warning
        dbms_output.put_line('+  SUGGESTION:  Apply ''' || rec.apply_name || ''' has parallelism > 1 and spilled data.');
        dbms_output.put_line('+    If the transaction workload is mainly medium size transactions (thousands of row changes per transaction),');
        dbms_output.put_line('+    consider reducing the ''_TXN_BUFFER_SIZE'' apply parameter to 10*parallelism to limit the');
        dbms_output.put_line('+    number of transactions stored in the Apply hash table, and memory consumption.');
        dbms_output.put_line('+    If your workload contains very large transactions (>10000 rows), consider');
        dbms_output.put_line('+    reducing this parameter even further, to 2*parallelism for example.  Note by reducing this');
        dbms_output.put_line('+    parameter you are trading off memory usage for performance.');
        dbms_output.put_line('+');
      end;

      if current_value > 50 then 
        dbms_output.put_line('+  SUGGESTION:  Apply ''' || rec.apply_name || ''' has parallelism > 1 and spilled data.');
        dbms_output.put_line('+    Consider reducing the ''_TXN_BUFFER_SIZE'' apply parameter to 10+parallelism to limit the');
        dbms_output.put_line('+    number of transactions stored in the Apply hash table, and memory consumption.');
        dbms_output.put_line('+    If your workload contains very large transactions (>100000 rows), consider');
        dbms_output.put_line('+    reducing this parameter even further, to 2+parallelism for example.  Note by reducing this');
        dbms_output.put_line('+    parameter you are trading off memory usage for performance.');
        dbms_output.put_line('+');
      end if;
    end loop;

    -- Both transformation function and dml handler defined for apply
    select count(*) into row_count
      from dba_apply a, dba_streams_rules r, dba_streams_transform_function t,
           dba_apply_dml_handlers d
     where a.rule_set_owner = r.rule_set_owner and a.rule_set_name = r.rule_set_name
       and r.rule_owner = t.rule_owner and r.rule_name = t.rule_name 
       and t.transform_function_name is not null
       and (a.apply_name = d.apply_name or d.apply_name is null)
       and (r.schema_name = d.object_owner or r.schema_name is null) 
       and (r.object_name = d.object_name or r.object_name is null)
       and r.subsetting_operation is null and d.error_handler = 'N'
       and d.user_procedure is not null;

    if row_count > 0 then 
      dbms_output.put_line('+  SUGGESTION:  One or more Apply processes have both DML handlers and transformation');
      dbms_output.put_line('+    functions defined.  Both DML handlers and transformations involve expensive');
      dbms_output.put_line('+    PL/SQL operations.  If you notice slow Apply performance, consider performing');
      dbms_output.put_line('+    all PL/SQL operations in either a transformation function or dml handler.');
      dbms_output.put_line('+');
    end if;

    -- Database-level supplemental logging defined but only a few tables replicated
    select count(*) into row_count from v$database where supplemental_log_data_pk = 'YES';
    select count(*) into capture_count from dba_capture_prepared_tables;
    if row_count > 0 and capture_count < 10 then
      dbms_output.put_line('+  SUGGESTION:  Database-level supplemental logging enabled but only a few tables');
      dbms_output.put_line('+    prepared for capture.  Database-level supplemental logging could write more');
      dbms_output.put_line('+    information to the redo logs for every update statement in the system.');
      dbms_output.put_line('+    If the number of tables you are interested in is small, you might consider');
      dbms_output.put_line('+    specifying supplemental logging of keys and columns on a per-table basis.');
      dbms_output.put_line('+    See the documentation for more information on per-table supplemental logging.');
      dbms_output.put_line('+');
    end if;
  end if;  
end;
/

prompt
prompt  ++
prompt  ++ <a name="Performance Checks">Performance Checks</a> ++
prompt  ++
prompt  ++ Note:  Performance only checked for enabled Streams processes!
prompt  ++        Aborted and disabled processes will not report performance warnings!
prompt
declare
  verbose boolean := TRUE;

  -- how far back capture must be before we generate a warning
  capture_latency_threshold    number := 300;  -- seconds
  -- how far back the apply reader must be before we generate a warning
  applyrdr_latency_threshold   number := 600;  -- seconds
  -- how far back the apply coordinator's LWM must be before we generate a warning
  applylwm_latency_threshold   number := 1200;  -- seconds
  -- how many messages should be unconsumed before generating a warning
  unconsumed_msgs_threshold    number := 300000;
  -- percentage of messages spilled before generating a warning
  spill_ratio_threshold        number := 25;
  -- how long queue can be up before signalling a warning
  spill_startup_threshold      number := 3600;  -- seconds
  -- how long logminer can spend spilling before generating a warning
  logminer_spill_threshold     number := 30000000;  -- microseconds 

  complex_rules boolean := FALSE;

  cursor capture_latency (threshold NUMBER) is 
   select capture_name, 86400 *(available_message_create_time - capture_message_create_time) latency
     from gv$streams_capture 
    where 86400 *(available_message_create_time - capture_message_create_time) > threshold;

  cursor apply_reader_latency (threshold NUMBER) is 
   select apply_name, 86400 *(dequeue_time - dequeued_message_create_time) latency
     from gv$streams_apply_reader
    where 86400 *(dequeue_time - dequeued_message_create_time) > threshold;

  cursor apply_lwm_latency (threshold NUMBER) is 
   select r.apply_name, 86400 *(r.dequeue_time - c.lwm_message_create_time) latency
     from gv$streams_apply_reader r, gv$streams_apply_coordinator c
    where r.apply# = c.apply# and r.apply_name = c.apply_name 
      and 86400 *(r.dequeue_time - c.lwm_message_create_time) > threshold;

  cursor queue_stats is
  select queue_schema, queue_name, num_msgs, spill_msgs, cnum_msgs, cspill_msgs,
         (cspill_msgs/DECODE(cnum_msgs, 0, 1, cnum_msgs) * 100) spill_ratio,  86400 *(sysdate - startup_time) alive
    from gv$buffered_queues;

  cursor logminer_spill_time (threshold NUMBER) is
  select c.capture_name, l.name, l.value from gv$streams_capture c, gv$logmnr_stats l
   where c.logminer_id = l.session_id 
     and name = 'microsecs spent in pageout' and value > threshold;  

  cursor complex_rule_sets_cap is
  select capture_name, owner, name from gv$rule_set r, dba_capture c 
   where c.rule_set_owner = r.owner and c.rule_set_name = r.name 
     and r.sql_executions > 0; 

  cursor complex_rule_sets_prop is
  select propagation_name, owner, name from gv$rule_set r, dba_propagation p
   where p.rule_set_owner = r.owner and p.rule_set_name = r.name 
     and r.sql_executions > 0; 

  cursor complex_rule_sets_apply is
  select apply_name, owner, name from gv$rule_set r, dba_apply a
   where a.rule_set_owner = r.owner and a.rule_set_name = r.name 
     and r.sql_executions > 0; 
begin
  for rec in capture_latency(capture_latency_threshold) loop
    dbms_output.put_line('+  WARNING:  The latency of the Capture process ''' || rec.capture_name
                         || ''' is ' || to_char(rec.latency, '99999999') || ' seconds!');
    if verbose then
      dbms_output.put_line('+    This measurement shows how far behind the Capture process is in processing the');
      dbms_output.put_line('+    redo log.  This may be due to slowdown in any of the common Streams components:');
      dbms_output.put_line('+    Capture, Propagation, and/or Apply.  If this latency is chronic and not due');
      dbms_output.put_line('+    to errors, consider the above suggestions for improving Capture, Propagation,');
      dbms_output.put_line('+    and Apply performance.');
      dbms_output.put_line('+');
    end if;
  end loop;

  for rec in apply_reader_latency(applyrdr_latency_threshold) loop
    dbms_output.put_line('+  WARNING:  The latency of the reader process for Apply ''' || rec.apply_name
                         || ''' is ' || to_char(rec.latency, '99999999') || ' seconds!');
    if verbose then
      dbms_output.put_line('+    This measurement shows how far behind the Apply reader is from when the message was');
      dbms_output.put_line('+    created, which in the normal case is by a Capture process.  In other words, ');
      dbms_output.put_line('+    the time between message creation and message dequeue by the Apply reader is too large.');
      dbms_output.put_line('+    If this latency is chronic and not due to errors, consider the above suggestions ');
      dbms_output.put_line('+    for improving Capture and Propagation performance.');
      dbms_output.put_line('+');
    end if;
  end loop;

  for rec in apply_lwm_latency(applylwm_latency_threshold) loop
    dbms_output.put_line('+  WARNING:  The latency of the coordinator process for Apply ''' || rec.apply_name
                         || ''' is ' || to_char(rec.latency, '99999999') || ' seconds!');
    if verbose then
      dbms_output.put_line('+    This measurement shows how far behind the low-watermark of the Apply process is');
      dbms_output.put_line('+    from when the message was first created, which in the normal case is by a Capture process.');
      dbms_output.put_line('+    The low-watermark is the most recent transaction (in terms of SCN) that has been');
      dbms_output.put_line('+    successfully applied, for which all previous transactions have also been applied.');
      dbms_output.put_line('+    A high latency can be due to long-running tranactions, many dependent transactions,');
      dbms_output.put_line('+    or slow Capture, Propagation, or Apply processes.');
      dbms_output.put_line('+');
    end if;
  end loop;

  -- check queue performance
  for rec in queue_stats loop
    if rec.num_msgs > unconsumed_msgs_threshold then
      dbms_output.put_line('+  WARNING:  There are ' || rec.num_msgs || ' unconsumed messages in queue ''' || rec.queue_schema ||
                           '''.''' || rec.queue_name || '''!');
      dbms_output.put_line('+');
    end if;

    if rec.spill_ratio > spill_ratio_threshold and rec.alive > spill_startup_threshold then
      dbms_output.put_line('+  WARNING:  The queue ''' || rec.queue_schema || '''.''' || rec.queue_name || ''' has spilled ' ||
                           round(rec.spill_ratio) || '% of its messages!');
      if verbose then
        dbms_output.put_line('+    Since the queue has been started, some large ratio of messages ');
        dbms_output.put_line('+    have been spilled to disk.  If no errors have occurred which might ');
        dbms_output.put_line('+    have caused the spills in the past (such as an aborted Apply or');
        dbms_output.put_line('+    Propagation process), and if you do not have long running transactions');
        dbms_output.put_line('+    in your workload, consider increasing the size of the Streams Pool');
        dbms_output.put_line('+    or increasing Apply parallelism.');
      end if;
      dbms_output.put_line('+');
    end if;

/*
    if rec.cspill_msgs > cum_spilled_msgs_threshold then
      dbms_output.put_line('+  WARNING:  There are ' || rec.cspill_msgs || 
                           ' cumulatively spilled messages in queue ''' || rec.queue_schema ||
                           '''.''' || rec.queue_name || '''!');
      if verbose then
        dbms_output.put_line('+    Since the queue has been started, some large number of messages ');
        dbms_output.put_line('+    have been spilled to disk.  If no errors have occurred which might ');
        dbms_output.put_line('+    have caused the spills in the past (such as an aborted Apply or');
        dbms_output.put_line('+    Propagation process), and if you do not have long running transactions');
        dbms_output.put_line('+    in your workload, consider increasing the size of the Streams Pool');
      end if;
      dbms_output.put_line('+');
    end if;
*/
  end loop;

   -- logminer spill time
  for rec in logminer_spill_time(logminer_spill_threshold) loop
    dbms_output.put_line('+  WARNING:  Excessive spill time for Capture process ''' 
                          || rec.capture_name || '''!');
    if verbose then
      dbms_output.put_line('+    Spill time implies that the Logminer component used by Capture ');
      dbms_output.put_line('+    does not have enough memory allocated to it.  This condition ');
      dbms_output.put_line('+    occurs when the system workload contains many DDLs and/or LOB');
      dbms_output.put_line('+    transactions.  Consider increasing the size of memory allocated to the');
      dbms_output.put_line('+    Capture process by increasing the ''_SGA_SIZE'' Capture parameter.');
    end if;
    dbms_output.put_line('+');
  end loop;

  -- sql executions in rule sets
  for rec in complex_rule_sets_cap loop
    complex_rules := TRUE;
    dbms_output.put_line('+  WARNING:  Complex rules exist for Capture process ''' 
                          || rec.capture_name || ' and rule set ''' 
                          || rec.owner || '''.''' || rec.name || '''!');
  end loop;

  for rec in complex_rule_sets_prop loop
    complex_rules := TRUE;
    dbms_output.put_line('+  WARNING:  Complex rules exist for Propagation process ''' 
                          || rec.propagation_name || ' and rule set ''' 
                          || rec.owner || '''.''' || rec.name || '''!');
  end loop;

  for rec in complex_rule_sets_apply loop
    complex_rules := TRUE;
    dbms_output.put_line('+  WARNING:  Complex rules exist for Apply process ''' 
                          || rec.apply_name || ' and rule set ''' 
                          || rec.owner || '''.''' || rec.name || '''!');
  end loop;

  if verbose and complex_rules then 
    dbms_output.put_line('+    Complex rules require SQL evaluations per message by a Streams ');
    dbms_output.put_line('+    process.  This slows down performance and should be avoided ');
    dbms_output.put_line('+    if possible.  Examine the rules in the rule set (for example');
    dbms_output.put_line('+    by looking at DBA_RULE_SET_RULES and DBA_RULES) and avoid uses');
    dbms_output.put_line('+    of the ''like'' operator and function/procedure calls in rule'); 
    dbms_output.put_line('+    conditions unless absolutely necessary.'); 
  end if;
  dbms_output.put_line('+');
end;
/
prompt ================================================================================
prompt ++ <a name="Wait Analysis">STREAMS Process Wait Analysis</a> ++ 


prompt
set lines 180
set numf 9999999999999
set pages 9999
set verify OFF

COL BUSY FORMAT A4
COL PERCENTAGE FORMAT 999D9
COL event wrapped

-- This variable controls how many minutes in the past to analyze
DEFINE minutes_to_analyze = 30

prompt  Analysis of last &minutes_to_analyze minutes of Streams processes
prompt

PROMPT Note:  When computing the busiest component, be sure to subtract the percentage where BUSY = 'NO'
PROMPT Note:  'no rows selected' means that the process was performing no busy work, or that no such process exists on the system.
PROMPT Note:  A null Wait Event implies running - either on the cpu or waiting for cpu

prompt
prompt ++ LOGMINER READER PROCESSES ++

COL LOGMINER_READER_NAME FORMAT A30 WRAP
BREAK ON LOGMINER_READER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON LOGMINER_READER_NAME;
SELECT c.capture_name || ' - reader' as logminer_reader_name, 
       ash_capture.event_count, ash_total.total_count, 
       ash_capture.event_count*100/ash_total.total_count percentage, 
       'YES' busy,
       ash_capture.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash_capture,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$logmnr_process lp, v$streams_capture c
WHERE lp.SID = ash_capture.SESSION_ID 
  AND lp.serial# = ash_capture.SESSION_SERIAL#
  AND lp.role = 'reader' and lp.session_id = c.logminer_id
ORDER BY logminer_reader_name, percentage;

prompt
prompt ++ LOGMINER PREPARER PROCESSES ++

COL LOGMINER_PREPARER_NAME FORMAT A30 WRAP
BREAK ON LOGMINER_PREPARER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON LOGMINER_PREPARER_NAME;
SELECT c.capture_name || ' - preparer' || lp.spid as logminer_preparer_name, 
       ash_capture.event_count, ash_total.total_count, 
       ash_capture.event_count*100/ash_total.total_count percentage, 
       'YES' busy,
       ash_capture.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash_capture,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$logmnr_process lp, v$streams_capture c
WHERE lp.SID = ash_capture.SESSION_ID 
  AND lp.serial# = ash_capture.SESSION_SERIAL#
  AND lp.role = 'preparer' and lp.session_id = c.logminer_id
ORDER BY logminer_preparer_name, percentage;

prompt
prompt ++ LOGMINER BUILDER PROCESSES ++

COL LOGMINER_BUILDER_NAME FORMAT A30 WRAP
BREAK ON LOGMINER_BUILDER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON LOGMINER_BUILDER_NAME;
SELECT c.capture_name || ' - builder' as logminer_builder_name, 
       ash_capture.event_count, ash_total.total_count, 
       ash_capture.event_count*100/ash_total.total_count percentage, 
       'YES' busy,
       ash_capture.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash_capture,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$logmnr_process lp, v$streams_capture c
WHERE lp.SID = ash_capture.SESSION_ID 
  AND lp.serial# = ash_capture.SESSION_SERIAL#
  AND lp.role = 'builder' and lp.session_id = c.logminer_id
ORDER BY logminer_builder_name, percentage;


prompt
prompt ++ CAPTURE PROCESSES ++

COL CAPTURE_NAME FORMAT A30 WRAP
BREAK ON CAPTURE_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON CAPTURE_NAME;
SELECT c.capture_name, 
       ash_capture.event_count, ash_total.total_count, 
       ash_capture.event_count*100/ash_total.total_count percentage, 
       DECODE(ash_capture.event, 
              'Streams capture: waiting for subscribers to catch up', 'NO',
              'Streams capture: resolve low memory condition', 'NO',
              'Streams capture: waiting for archive log', 'NO',
              'YES') busy,
       ash_capture.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash_capture,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$streams_capture c
WHERE c.SID = ash_capture.SESSION_ID and c.serial# = ash_capture.SESSION_SERIAL#
ORDER BY capture_name, percentage;



prompt
prompt ++ PROPAGATION SENDER PROCESSES ++

COL PROPAGATION_NAME FORMAT A30 WRAP
BREAK ON PROPAGATION_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON PROPAGATION_NAME;
SELECT ('"'||vps.queue_schema||'"."'||vps.queue_name||
          '"=>'||vps.dblink) as propagation_name,
       ash.event_count, ash_total.total_count, 
       ash.event_count*100/ash_total.total_count percentage, 
       DECODE(ash.event, 
              'SQL*Net more data to dblink', 'NO',
              'SQL*Net message from dblink', 'NO',
              'YES') busy,
       ash.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$propagation_sender vps, x$kwqps xps
WHERE xps.kwqpssid = ash.SESSION_ID and xps.kwqpsser = ash.SESSION_SERIAL#
  AND xps.kwqpsqid = vps.queue_id and vps.dblink = xps.KWQPSDBN
ORDER BY propagation_name, percentage;



prompt
prompt ++ PROPAGATION RECEIVER PROCESSES ++

COL PROPAGATION_RECEIVER_NAME FORMAT A30 WRAP
BREAK ON PROPAGATION_RECEIVER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON PROPAGATION_RECEIVER_NAME;
SELECT ('"'||vpr.src_queue_schema||'"."'||vpr.src_queue_name||
          '@' || vpr.src_dbname|| '"=>'||global_name) 
          as propagation_receiver_name,
       ash.event_count, ash_total.total_count, 
       ash.event_count*100/ash_total.total_count percentage, 
       DECODE(ash.event, 
              'Streams AQ: enqueue blocked on low memory', 'NO',
              'Streams AQ: enqueue blocked due to flow control', 'NO',
              'YES') busy,
       ash.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$propagation_receiver vpr, x$kwqpd xpd, global_name
WHERE xpd.kwqpdsid = ash.SESSION_ID and xpd.kwqpdser = ash.SESSION_SERIAL#
  AND xpd.kwqpdsqn = vpr.src_queue_name 
  AND xpd.kwqpdsqs = vpr.src_queue_schema and xpd.kwqpddbn = vpr.src_dbname
ORDER BY propagation_receiver_name, percentage;



prompt
prompt ++ APPLY READER PROCESSES ++

COL APPLY_READER_NAME FORMAT A30 WRAP
BREAK ON APPLY_READER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON APPLY_READER_NAME;
SELECT a.apply_name as apply_reader_name,
       ash.event_count, ash_total.total_count, 
       ash.event_count*100/ash_total.total_count percentage, 
       DECODE(ash.event, 
              'rdbms ipc message', 'NO',
              'YES') busy,
       ash.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$streams_apply_reader a
WHERE a.sid = ash.SESSION_ID and a.serial# = ash.SESSION_SERIAL#
ORDER BY apply_reader_name, percentage;



prompt
prompt ++ APPLY COORDINATOR PROCESSES ++

COL APPLY_COORDINATOR_NAME FORMAT A30 WRAP
BREAK ON APPLY_COORDINATOR_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON APPLY_COORDINATOR_NAME;
SELECT a.apply_name as apply_coordinator_name,
       ash.event_count, ash_total.total_count, 
       ash.event_count*100/ash_total.total_count percentage, 
       'YES' busy,
       ash.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$streams_apply_coordinator a
WHERE a.sid = ash.SESSION_ID and a.serial# = ash.SESSION_SERIAL#
ORDER BY apply_coordinator_name, percentage;



prompt
prompt ++ APPLY SERVER PROCESSES ++

COL APPLY_SERVER_NAME FORMAT A30 WRAP
BREAK ON APPLY_SERVER_NAME;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON APPLY_SERVER_NAME;
SELECT a.apply_name || ' - ' || a.server_id as apply_server_name,
       ash.event_count, ash_total.total_count, 
       ash.event_count*100/ash_total.total_count percentage, 
       'YES' busy,
       ash.event
FROM (SELECT SESSION_ID,
             SESSION_SERIAL#,
             EVENT,
             COUNT(sample_time) AS EVENT_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60
       GROUP BY session_id, session_serial#, event) ash,
     (SELECT COUNT(DISTINCT sample_time) AS TOTAL_COUNT
       FROM  v$active_session_history
       WHERE sample_time > sysdate - &minutes_to_analyze/24/60) ash_total,
     v$streams_apply_server a
WHERE a.sid = ash.SESSION_ID and a.serial# = ash.SESSION_SERIAL#
ORDER BY apply_server_name, percentage;

set timing off
set markup html off
clear col
clear break
spool
prompt   Turning Spool OFF!!!
spool off


