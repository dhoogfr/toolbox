REM
REM This script collects details related to CDC setup and activity. 
REM 
REM  It  is recommended to run with markup html ON (default is on) and generate an 
REM  HTML file for web viewing.
REM  Please provide the output in HTML format when Oracle (support or development) requests 
REM  CDC configuration details. 
REM
REM NOTE: 
REM  This main consideration of this note is to provide configuration details although 
REM  some performance detail is provided. The note should be used in conjunction with 
REM  the Streams Healthcheck -
REM  <Note:273674.1> Streams Configuration Report and Health Check Script which also provides
REM  detailed performance inforation relating to Capture and Apply processes. 
REM
REM  To convert output to a text file viewable with a text editor, 
REM    change the HTML ON to HTML OFF in the set markup command
REM  Remember to set up a spool file to capture the output
REM

-- connect / as sysdba
set markup HTML ON entmap off

alter session set nls_date_format='HH24:Mi:SS MM/DD/YY';
set heading off

select 'CDC Configuration Check (V1.0.0) for '||global_name||' on Instance='||instance_name||' generated: '||sysdate o  from global_name, v$instance;
set heading on timing off

set pages 9999

prompt Publishers: <a href="#Publishers"> Publishers </a> <a href="#PubPrivs"> Privileges </a> 

prompt Change Sets: <a href="#ChangeSets"> Change Sets </a> <a href="#ChangeSources"> Change Sources </a> <a href="#ChangeTabs"> Change Tables </a> 

prompt Subscribers: <a href="#ChangeSetSubs"> Change Sets </a> <a href="#ChangeTabs"> Change Tables </a> <a href="#ChangeSetTabSubs"> Views </a> 

prompt Processes: <a href="#CapDistHotLog"> Capture </a> <a href="#ApplyProc"> Apply </a> <a href="#Propagation"> Propagation </a>  

prompt Processes: <a href="#AddAutoLog"> Additional Autolog Details </a>

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="Database">Database Information</a> ++
COLUMN MIN_LOG FORMAT A7
COLUMN PK_LOG FORMAT A6
COLUMN UI_LOG FORMAT A6
COLUMN FK_LOG FORMAT A6
COLUMN ALL_LOG FORMAT A6
COLUMN FORCE_LOG FORMAT A10
COLUMN archive_change# format 999999999999999999
COLUMN archivelog_change# format 999999999999999999
COLUMN NAME HEADING 'Name'
COLUMN platform_name format a30 wrap
COLUMN current_scn format 99999999999999999
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
prompt ++ <a name="Parameters">Parameters</a> ++

column NAME format a30
column VALUE format a30
select NAME, VALUE from v$parameter where name in ('java_pool_size','compatible','parallel_max_servers','job_queue_processes',
'aq_tm_processes','processes','sessions','streams_pool_size','undo_retention','open_links','global_names','remote_login_passwordfile');

prompt ++ <a name="aq_tm_processes">AQ_TM_PROCESSES should indicate QMON AUTO TUNING IN FORCE</a> ++
column NAME format a20
column NULL? format a20
select inst_id, name, nvl(value,'AUTO TUNING IN OPERATION') "SHOULD INDICATE AUTO TUNING"
from gv$spparameter
where name = 'aq_tm_processes';

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="Publishers">Publishers</a> ++

COLUMN PUBLISHER HEADING 'Change Set Publishers' FORMAT A30
select distinct PUBLISHER from change_sets where PUBLISHER is not null;
COLUMN PUBLISHER HEADING 'Change Source Publishers' FORMAT A30
select distinct PUBLISHER from change_sources where PUBLISHER is not null;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="PubPrivs">Publishers Privilieges</a> ++
prompt ++ <a name="PubRoles">--Roles</a> ++

COLUMN GRANTEE HEADING 'GRANTEE' FORMAT A30
COLUMN GRANTED_ROLE HEADING 'GRANTED_ROLE' FORMAT A30
COLUMN ADMIN_OPTION HEADING 'ADMIN_OPTION' FORMAT A3
COLUMN DEFAULT_ROLE HEADING 'DEFAULT_ROLE' FORMAT A3
select GRANTEE ,GRANTED_ROLE,ADMIN_OPTION,DEFAULT_ROLE from dba_role_privs 
where GRANTEE in (select distinct PUBLISHER from change_sets where PUBLISHER is not null) 
or GRANTEE in (select distinct PUBLISHER from change_sources where PUBLISHER is not null) 
order by GRANTEE;

prompt
prompt ++ <a name="SysPrivs">--System Privilieges</a> ++
prompt
COLUMN GRANTEE HEADING 'GRANTEE' FORMAT A30
COLUMN PRIVILEGE HEADING 'PRIVILEGE' FORMAT A40
COLUMN ADMIN_OPTION HEADING 'ADMIN_OPTION' FORMAT A3
select GRANTEE,PRIVILEGE,ADMIN_OPTION from dba_sys_privs 
where GRANTEE in (select distinct PUBLISHER from change_sets where PUBLISHER is not null) 
or GRANTEE in (select distinct PUBLISHER from change_sources where PUBLISHER is not null)
order by GRANTEE;

prompt
prompt ++ <a name="TabPrivs">--Table Privilieges</a> ++
COLUMN GRANTEE format a20
COLUMN TABLE_NAME format a40
COLUMN PRIVILEGE format a10
select GRANTEE, OWNER||'.'||TABLE_NAME "TABLE_NAME", PRIVILEGE 
from dba_tab_privs 
where GRANTEE in (select distinct PUBLISHER from change_sets where PUBLISHER is not null) 
or GRANTEE in (select distinct PUBLISHER from change_sources where PUBLISHER is not null)
order by GRANTEE, TABLE_NAME;


prompt
prompt ============================================================================================
prompt
prompt ++ <a name="SuppLogging">Tables with Supplemental Logging</a> ++
column OWNER format a30
column TABLE_NAME format a30 wrap
column TABLE Format a25
select owner||'.'||table_name "TABLE", LOG_GROUP_NAME, LOG_GROUP_TYPE from DBA_LOG_GROUPS;

prompt
prompt ++ <a name="SuppLogCols">Supplemental logging columns</a> ++
COLUMN LOG_GROUP_NAME format a25
COLUMN COLUMN_NAME format a25
select owner||'.'||table_name "Table", LOG_GROUP_NAME, COLUMN_NAME from DBA_LOG_GROUP_COLUMNS;


prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeSets">Change Sets</a> ++
prompt
column PUBLISHER format a20
column SET_NAME format a20
column CHANGE_SOURCE_NAME format a20
select PUBLISHER, SET_NAME, CHANGE_SOURCE_NAME, CREATED from change_sets;

prompt
prompt ++ <a name="ChangeSets">Change Set Status</a> ++
prompt
column c HEADING 'Capture|Enabled' format a7
column LOWEST_SCN format 999999999999999999
select PUBLISHER, SET_NAME, CAPTURE_ENABLED c, PURGING, BEGIN_DATE, END_DATE, LOWEST_SCN, STOP_ON_DDL  from change_sets;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeSources">Change Sources</a> ++
prompt
column SOURCE_NAME format a15
column SOURCE_DESCRIPTION format a30
column SOURCE_DATABASE format a40
select SOURCE_NAME, SOURCE_DESCRIPTION, CREATED, SOURCE_TYPE, SOURCE_DATABASE, SOURCE_ENABLED "Enabled" 
from change_sources;

prompt ============================================================================================
prompt
prompt ++ <a name="TabPrep">Tables Prepared for Capture</a> ++
prompt
COLUMN table_owner format a30 HEADING 'Table|Owner'
COLUMN table_name format a30 HEADING 'Table|Name'
COLUMN timestamp heading 'Timestamp'
COLUMN supplemental_log_data_pk HEADING 'PK|Logging'
COLUMN supplemental_log_data_ui HEADING 'UI|Logging'
COLUMN supplemental_log_data_fk HEADING 'FK|Logging'
COLUMN supplemental_log_data_all HEADING 'All|Logging'

select * from dba_capture_prepared_tables order by table_owner,table_name;

prompt ++ <a name="SchemaPrep">Schemas Prepared for Capture</a> ++
select * from dba_capture_prepared_schemas order by schema_name;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="CapDistHotLog">Capture / Distributed HotLog Case</a> ++

select s.SOURCE_NAME, c.CAPTURE_NAME, c.QUEUE_NAME, c.STATUS
from change_sources s, dba_capture c
where s.capture_name=c.capture_name
and s.capture_queue_name=c.queue_name
and s.source_database=c.source_database
and s.publisher=c.queue_owner;

prompt
prompt ++ <a name="CapProcDistHotLog">Capture process current state</a> ++

column CAPTURE_NAME format a25
column SET_NAME format a20
column STATE format a60
column TOTAL_MESSAGES_CAPTURED HEADING 'Captured|MSGs'
column TOTAL_MESSAGES_ENQUEUED HEADING 'Enqueued|MSGs'
select s.PUBLISHER, s.SOURCE_NAME, c.capture_name, c.state 
from v$streams_capture c, change_sources s
where c.capture_name = s.capture_name;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="HotLog">Capture / other configurations</a> ++

Column PUBLISHER format a10
column change_set format a20
column CAPTURE_NAME format a25
column queue_name format a25
column ERROR_MESSAGE format a30

select PUBLISHER, s.SET_NAME change_set, c.CAPTURE_NAME, c.QUEUE_NAME, STATUS, ERROR_MESSAGE 
from dba_capture c, change_sets s
where c.capture_name=s.capture_name
and   c.queue_name = s.queue_name
and   c.queue_owner = s.publisher;

prompt
prompt ++ <a name="CapHotLog">Capture process current state</a> ++
column CAPTURE_NAME format a25
column SET_NAME format a20
column STATE format a60
column TOTAL_MESSAGES_CAPTURED HEADING 'Captured|MSGs'
column TOTAL_MESSAGES_ENQUEUED HEADING 'Enqueued|MSGs'

select s.PUBLISHER, s.SET_NAME, c.capture_name, c.state 
from v$streams_capture c, change_sets s
where c.capture_name = s.capture_name;

prompt ============================================================================================
prompt
prompt ++ <a name="BuffPubs">Buffered Publishers</a> ++
select * from gv$buffered_publishers;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ApplyProc">Apply process re Change Sets</a> ++
prompt

Column PUBLISHER format a15
column change_set format a20
column apply_name format a25
column queue_name format a25
column ERROR_MESSAGE format a30
select PUBLISHER, s.SET_NAME change_set, a.APPLY_NAME, a.QUEUE_NAME, STATUS, ERROR_MESSAGE
from dba_apply a, change_sets s
where a.apply_name=s.apply_name
and   a.queue_name = s.queue_name
and   a.queue_owner = s.publisher;

prompt
prompt ++ <a name="BuffSubs">Buffered Subscribers</a> ++
select * from gv$buffered_subscribers;


prompt
prompt ============================================================================================
prompt
prompt ++ <a name="BuffQs">Buffered Queues</a> ++

column QUEUE format a40
select QUEUE_SCHEMA||'.'||QUEUE_NAME Queue, NUM_MSGS-SPILL_MSGS "Memory MSGs", SPILL_MSGS "Spilled", CNUM_MSGS Cummulative 
from v$buffered_queues;


prompt
prompt ============================================================================================
prompt
prompt ++ <a name="Propagation">Propagation</a> ++
column "Source Queue" format a30
column "Dest Queue" format a35
column "Destination Name" format a35
select PROPAGATION_NAME, DESTINATION_DBLINK "Destination Name", SOURCE_QUEUE_OWNER||'.'||SOURCE_QUEUE_NAME "Source Queue",
DESTINATION_QUEUE_OWNER||'.'||DESTINATION_QUEUE_NAME "Dest Queue",  
STATUS, ERROR_MESSAGE 
from dba_propagation;

prompt ++ <a name="QueueSched">Queue Schedules</a> ++
column SOURCE format a30
column DESTINATION format a65
column LAST_ERROR_MSG format a30
select SCHEMA||'.'||QNAME "SOURCE", DESTINATION, SCHEDULE_DISABLED, TOTAL_NUMBER, LAST_ERROR_MSG, LAST_ERROR_DATE 
from dba_queue_schedules;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeTabs">Change Tables</a> ++
column "Change Set"   format a20
column "Change Table" format a25
column "Source Table" format a25
column CREATED_SCN format 999999999999999999
select CHANGE_SET_NAME "Change Set", CHANGE_TABLE_SCHEMA||'.'||CHANGE_TABLE_NAME "Change Table", 
	SOURCE_SCHEMA_NAME||'.'||SOURCE_TABLE_NAME "Source Table", 
	CAPTURED_VALUES, CREATED, CREATED_SCN 
from change_tables;

prompt 
prompt ++ <a name="ChangeColsPerTab">Change Columns For Each Change Table</a> ++

column "Change Table" format a30
column COLUMN_NAME format a20
column DATA_TYPE format a10
select  CHANGE_TABLE_SCHEMA||'.'||CHANGE_TABLE_NAME "Change Table", PUB_ID, COLUMN_NAME, DATA_TYPE 
from DBA_PUBLISHED_COLUMNS 
order by  "Change Table", PUB_ID, COLUMN_NAME;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="Users">Users Eligible to be Subscribers for Change Tables</a> ++
column "User" format a15
column "Change Set"   format a20
column "Channge Table" format a20
column "Source Table" format a20
select t.GRANTEE "User", CHANGE_SET_NAME "Change Set", t.OWNER||'.'||t.TABLE_NAME "Channge Table", s.SOURCE_SCHEMA_NAME||'.'||s.SOURCE_TABLE_NAME "Source Table"
from dba_tab_privs t, dba_source_tables s, change_tables c
where t.PRIVILEGE ='SELECT'
and t.OWNER=c.CHANGE_TABLE_SCHEMA
and t.TABLE_NAME=c.CHANGE_TABLE_NAME
and c.SOURCE_SCHEMA_NAME=s.SOURCE_SCHEMA_NAME
and c.SOURCE_TABLE_NAME=s.SOURCE_TABLE_NAME;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeSetSubs">Change Set Subscribers</a> ++
column "Subscriber" format a15
column SUBSCRIPTION_NAME format a20
column "Change Set" format a20
column LAST_EXTENDED heading "Extended"
column LAST_PURGED heading "Purged"
select USERNAME "Subscriber", SET_NAME "Change Set", SUBSCRIPTION_NAME, CREATED, LAST_EXTENDED, LAST_PURGED 
FROM DBA_SUBSCRIPTIONS;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeSetTabSubs">Change Set Tables Subscriptions / Subscribers Views</a> ++
column VIEW_NAME format a15
column "Change Table" format a20
select s.SUBSCRIPTION_NAME, s.VIEW_NAME, 
	c.CHANGE_TABLE_SCHEMA||'.'||c.CHANGE_TABLE_NAME "Change Table", 
	s.CHANGE_SET_NAME "Change Set" 
from DBA_SUBSCRIBED_TABLES s, CHANGE_TABLES c 
where c.SOURCE_SCHEMA_NAME = s.SOURCE_SCHEMA_NAME 
and c.SOURCE_TABLE_NAME = s.SOURCE_TABLE_NAME 
and c.CHANGE_SET_NAME = s.CHANGE_SET_NAME;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="ChangeTabColSubs">Change Table / Columns Subscriptions</a> ++
column CHANGE_SET_NAME format a20
column COLUMN_NAME format a15
column DATA_TYPE format a10
select sc.SUBSCRIPTION_NAME, s.VIEW_NAME, s.CHANGE_SET_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.PUB_ID
from DBA_SUBSCRIBED_COLUMNS sc, DBA_SUBSCRIBED_TABLES s, DBA_PUBLISHED_COLUMNS c
where sc.SOURCE_SCHEMA_NAME = s.SOURCE_SCHEMA_NAME
and   sc.SOURCE_TABLE_NAME  = s.SOURCE_TABLE_NAME
and   sc.SOURCE_TABLE_NAME  = c.SOURCE_TABLE_NAME
and   sc.SOURCE_SCHEMA_NAME = c.SOURCE_SCHEMA_NAME
and   s.CHANGE_SET_NAME     = c.CHANGE_SET_NAME
and   sc.COLUMN_NAME        = c.COLUMN_NAME
order by sc.SUBSCRIPTION_NAME, s.VIEW_NAME, s.CHANGE_SET_NAME, c.COLUMN_NAME;

prompt
prompt ============================================================================================
prompt
prompt ++ <a name="AddAutoLog">Additional Information relevant to AutoLog</a> ++
prompt +++ <a name="AddAutoLogParms">Autolog Parameters</a> ++
column NAME format a30
column VALUE format a30
select NAME, VALUE from v$parameter where name like 'log_archive%';

prompt
prompt ++ <a name="Logfiles">Logfiles</a> ++
select THREAD#, GROUP#, BYTES/1024/1024 from V$LOG; 

prompt
prompt ++ <a name="Standby Logs">Standbylogs</a> ++
SELECT GROUP#, THREAD#, SEQUENCE#, BYTES/1024/1024, ARCHIVED, STATUS FROM V$STANDBY_LOG;


set timing off
set markup html off
clear col
clear break
spool
prompt   End Of Script
spool off
