/* run this script as a dba user, passing the logfile as parameter
   This script has been created to assist in the migrations of the 9i databases at OLV
   
       @get_db_overview.sql <logfile>
   
    this will generate a logfile in the current directory
    
*/


set pagesize 9999
set linesize 150
set serveroutput on
set trimspool on
set echo off
set feedback 1

spool &1

--------------------------------------------- DB ----------------------------------------------------------------------

column platform_name format a40
column name format a15
column db_unique_name format a20

select dbid, name, created, log_mode 
from v$database;

--------------------------------------------- DB PARAMETERS ------------------------------------------------------------
prompt
prompt PARAMETERS
prompt __________


set linesize 180
set pagesize 9999


COLUMN display_value FORMAT a15 word_wrapped
COLUMN value FORMAT a75 word_wrapped
COLUMN name FORMAT a35
column type format 999

select x.inst_id inst_id,ksppinm name,ksppity type,
       ksppstvl value, ksppstdf isdefault
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ( ksppstdf = 'FALSE'
            or translate(ksppinm,'_','#') like '##%' 
          --  or translate(ksppinm,'_','#') like '#%'
          )
order by x.inst_id, ksppinm;

--------------------------------------------- DB PROPERTIES ------------------------------------------------------------
prompt
prompt DB PROPERTIES
prompt _____________

column property_value format a40

select property_name, property_value 
from database_properties
order by property_name;

--------------------------------------------- INSTALLED OPTIONS --------------------------------------------------------

prompt
prompt INSTALLED OPTIONS
prompt _________________


column comp_name format a50

select comp_name, version, status 
from dba_registry 
order by comp_name;

--------------------------------------------- DB SIZES ------------------------------------------------------------------
prompt
prompt DB - Sizes
prompt __________

column name format a25 heading "tablespace name" 
column space_mb format 99g999g990D99 heading "curr df mbytes" 
column maxspace_mb format 99g999g990D99 heading "max df mbytes" 
column used format 99g999g990D99 heading "used mbytes" 
column df_free format 99g999g990D99 heading "curr df free mbytes"
column maxdf_free format 99g999g990D99 heading "max df free mbytes"
column pct_free format 990D99 heading "% free"
column pct_maxfile_free format 990D99 heading "% maxfile free"

break on report

compute sum of space_mb on report
compute sum of maxspace_mb on report
compute sum of df_free on report
compute sum of maxdf_free on report
compute sum of used on report

 
select df.tablespace_name name, df.space space_mb, df.maxspace maxspace_mb, (df.space - nvl(fs.freespace,0)) used,
       nvl(fs.freespace,0) df_free, (nvl(fs.freespace,0) + df.maxspace - df.space) maxdf_free, 
       100 * (nvl(fs.freespace,0) / df.space) pct_free, 
       100 * ((nvl(fs.freespace,0) + df.maxspace - df.space) / df.maxspace) pct_maxfile_free
from ( select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_temp_files
       group by tablespace_name
     ) df,
     ( select tablespace_name, sum(bytes)/1024/1024 freespace
       from dba_free_space
       group by tablespace_name
     ) fs
where df.tablespace_name = fs.tablespace_name(+)
order by name;

clear breaks


--------------------------------------------- TABLESPACE INFO --------------------------------------------------------------

prompt
prompt tablespace info
prompt _______________

column max_mb format 9G999G990D99
column curr_mb format 9G999G990D99
column free_mb format 9G999G990D99
column pct_free format 900D99 heading "%FREE"
column NE format 9G999G999D99
column SSM format a6
column AT format a8
column tablespace_name format a20
column EM format a10
column contents format a15
column block_size format 99999 heading bsize

select A.tablespace_name, block_size, A.contents, extent_management EM, allocation_type AT,
       segment_space_management ssm, decode(allocation_type, 'UNIFORM',next_extent/1024,'') NE,
       B.max_mb, B.curr_mb,
       (B.max_mb - B.curr_mb) + nvl(c.free_mb,0) free_mb, 
       ((100/B.max_mb)*(B.max_mb - B.curr_mb + nvl(c.free_mb,0))) pct_free
from dba_tablespaces A,
     ( select tablespace_name, sum(bytes)/1024/1024 curr_mb, 
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 curr_mb,
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_temp_files
       group by tablespace_name
     ) B,
     ( select tablespace_name, sum(bytes)/1024/1024 free_mb
       from dba_free_space
       group by tablespace_name
     ) C
where A.tablespace_name = B.tablespace_name
      and A.tablespace_name = C.tablespace_name(+)
order by tablespace_name;

--------------------------------------------- DF DETAILS ------------------------------------------------------------------

column curr_mb format 9G999G990D99
column max_mb format 9G9999990D99
column incr_mb format 9G999G990D99
column file_name format a75
--column file_name format a60
column tablespace_name format a20
break on tablespace_name skip 1
set linesize 160
set pagesize 999

prompt
prompt datafiles info
prompt ______________

select A.tablespace_name, file_id, file_name, bytes/1024/1024 curr_mb, autoextensible, 
       maxbytes/1024/1024 max_mb, (increment_by * block_size)/1024/1024 incr_mb
from ( select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_data_files
       union all
       select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_temp_files
     ) A, dba_tablespaces B
where A.tablespace_name = B.tablespace_name
order by A.tablespace_name, file_name;

clear breaks;

--------------------------------------------- OWNER / TBS MATRIX ------------------------------------------------------------------

prompt
prompt OWNER / TBS MATRIX
prompt __________________

column mb format 9G999G999D99

break on owner skip 1
compute sum of mb on owner

select owner, tablespace_name, sum(bytes)/1024/1024 mb, count(*) counted
from dba_segments
group by owner, tablespace_name
order by owner, tablespace_name;

clear breaks

--------------------------------------------- OBJECTS ------------------------------------------------------------------

prompt
prompt OBJECTS
prompt __________________

break on owner skip 1 on object_type
compute sum of counted on owner
column counted format 9G999G999G999

select owner, object_type, status, count(*) counted
from dba_objects
where owner not in 
        ( 'DBSNMP','ORACLE_OCM','OUTLN','PUBLIC','SYS','SYSMAN','SYSTEM', 'TSMSYS','WMSYS','APPQOSSYS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB'
        )
group by owner, object_type, status
order by owner, object_type, status;

clear breaks

--------------------------------------------- ONLINE REDO INFO ----------------------------------------------------------------

prompt
prompt ONLINE REDO INFO
prompt ________________

column member format a65
column type format a10
column status format a15
column arch format a4
column mb format 9G999G999

break on type on thread# nodup skip 1 on type nodup on GROUP# nodup

select type, A.thread#, A.group#, B.member, A.bytes/1024/1024 mb,A.status, arch
from ( select group#, thread#, bytes, status, archived arch
       from v$log
       union all
       select group#, thread#, bytes, status, archived arch
       from v$standby_log
     ) A, v$logfile B
where A.group# = B.group#
order by type, A.thread#, A.group#, B.member;

clear breaks


--------------------------------------------- REDO SIZES ------------------------------------------------------------------

prompt
prompt REDO STATISTICS
prompt _______________

column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

column start_day format a22
column end_day format a22
column days_between format 99
column avg_archived_per_day format a13 heading avg_gen

select to_char(min(dag), 'DD/MM/YYYY HH24:MI:SS') start_day, to_char(max(dag) + 1 - 1/(24*60*60), 'DD/MM/YYYY HH24:MI:SS') end_day,
       (max(dag) - min(dag) + 1) days_between,
       to_char(avg(gen_archived_size),'9G999G999D99') avg_archived_per_day
from ( select trunc(completion_time) dag, sum(blocks * block_size)/1024/1024 gen_archived_size
       from v$archived_log
       where standby_dest = 'NO'
             and months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );

/* 
archived redo over the (max) last 10 days
*/
column day_arch_size format 99G999D99
column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

select to_char(day, 'DD/MM/YYYY') day, to_char(day,'DAY') dayname, day_arch_size, day_arch#, graph
from ( select trunc(completion_time) day, sum(blocks * block_size)/1024/1024 day_arch_size, count(*) day_arch#,
              rpad('*',floor(count(*)/10),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 10
       group by trunc(completion_time)
       order by day
     );
     
/*
archived redo per hour over the (max) last 2 days
*/
column hour_arch_size format 99G999D99
column hour_arch# format 9G999
column graph format a15
column dayname format a12
column dayhour format a18
break on dayname skip 1

select to_char(dayhour,'DAY') dayname, to_char(dayhour, 'DD/MM/YYYY HH24:MI') dayhour, hour_arch_size, hour_arch#, graph
from ( select trunc(completion_time, 'HH') dayhour, sum(blocks * block_size)/1024/1024 hour_arch_size, count(*) hour_arch#,
              rpad('*',floor(count(*)/4),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 2
       group by trunc(completion_time, 'HH')
       order by dayhour
     );
     
clear breaks;

--------------------------------------------- USERS ------------------------------------------------------------------

prompt
prompt USERS
prompt _____


column username format a20
column password format a20
column account_status format a20
column default_tablespace format a20
column temporary_tablespace format a20
column profile format a15

select username, password, account_status, lock_date, expiry_date, default_tablespace, temporary_tablespace, created, profile
from dba_users
order by username;

--------------------------------------------- TS QUOTA ------------------------------------------------------------------

prompt
prompt TS QUOTA
prompt __________
prompt(0 = unlimited)

column mb format 9G999G999D99

select username, tablespace_name, (decode (max_bytes, -1,0, max_bytes))/1024/1024 mb 
from dba_ts_quotas 
order by username, tablespace_name;

--------------------------------------------- PRIVILEGES ------------------------------------------------------------------

prompt
prompt SYS PRIVILEGES
prompt ______________

column grantee format a30
break on grantee skip 1

select grantee, privilege, admin_option
from dba_sys_privs
where grantee not in 
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP','APPQOSSYS', 'ANONYMOUS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB','DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC'
         )
order by grantee, privilege;



clear breaks

prompt
prompt ROLE PRIVILEGES
prompt _______________

column grantee format a30
break on grantee skip 1

select grantee, granted_role, admin_option, default_role
from dba_role_privs
where grantee not in 
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP', 'CTXSYS', 'DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','EXFSYS','MDSYS','ORDSYS','XDB','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC'
         )
order by grantee, granted_role;

clear breaks

prompt
prompt OBJECT PRIVILEGES
prompt _________________

column grantee format a30
column privilege format a30

break on grantee skip 1

select grantee, owner, table_name, privilege, grantable, hierarchy
from dba_tab_privs
where grantee not in 
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP','APPQOSSYS', 'ANONYMOUS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB','DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','ADM_PARALLEL_EXECUTE_TASK','CTXAPP','DBFS_ROLE','HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_SELECT_ROLE',
          'ORDADMIN','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC'
         )
order by grantee, owner, table_name, privilege;

clear breaks

prompt
prompt NON STANDARD ROLES
prompt __________________

column grantee format a30
column privilege format a30

break on grantee skip 1

select role, password_required
from dba_roles
where role not in 
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP','APPQOSSYS', 'ANONYMOUS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB','DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','ADM_PARALLEL_EXECUTE_TASK','CTXAPP','DBFS_ROLE','HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_SELECT_ROLE',
          'ORDADMIN','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC',
          'AUTHENTICATEDUSER','JMXSERVER'
         )
order by role;

clear breaks

--------------------------------------------- SYNONYMS ------------------------------------------------------------------

prompt
prompt SYNONYMS
prompt _________

break on owner skip 1

select owner, synonym_name, table_owner, table_name
from dba_synonyms
where owner not in
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP','APPQOSSYS', 'ANONYMOUS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB','DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','ADM_PARALLEL_EXECUTE_TASK','CTXAPP','DBFS_ROLE','HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_SELECT_ROLE',
          'ORDADMIN','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC',
          'AUTHENTICATEDUSER','JMXSERVER'
         )
order by owner, synonym_name;

clear breaks

prompt
prompt NON DEFAULT PUBLIC SYNONYMS 
prompt ____________________________

break on table_owner skip 1

select table_owner, table_name, synonym_name
from dba_synonyms
where owner = 'PUBLIC'
      and table_owner not in
        ( 'SYS', 'SYSTEM', 'TSMSYS', 'WMSYS','SYSMAN', 'OUTLN', 'DBSNMP', 'PERFSTAT', 'UPTIME',
          'ANALYZETHIS', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'DBA', 'DELETE_CATALOG_ROLE', 
          'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 
          'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'OEM_MONITOR', 'OUTLN', 'PANDORA', 'PERFSTAT', 
          'PUBLIC', 'SELECT_CATALOG_ROLE', 'SYS', 'SYSTEM', 'WMSYS', 'WM_ADMIN_ROLE', 'TIVOLI_ROLE',
          'CONNECT', 'JAVADEBUGPRIV', 'RECOVERY_CATALOG_OWNER', 'RESOURCE', 'TIVOLI', 'JAVASYSPRIV',
          'GLOBAL_AQ_USER_ROLE', 'JAVAUSERPRIV', 'JAVAIDPRIV', 'EJBCLIENT', 'JAVA_ADMIN', 'JAVA_DEPLOY',
          'MGMT_USER','MGMT_VIEW','OEM_ADVISOR','ORACLE_OCM','SCHEDULER_ADMIN','DIP','APPQOSSYS', 'ANONYMOUS',
          'CTXSYS','EXFSYS','MDSYS','ORDDATA','ORDPLUGINS','ORDSYS','SI_INFORMTN_SCHEMA','XDB','DATAPUMP_EXP_FULL_DATABASE',
          'DATAPUMP_IMP_FULL_DATABASE','ADM_PARALLEL_EXECUTE_TASK','CTXAPP','DBFS_ROLE','HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_SELECT_ROLE',
          'ORDADMIN','XDBADMIN','XDB_SET_INVOKER','XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC',
          'AUTHENTICATEDUSER','JMXSERVER'
         )
order by table_owner, table_name;

clear breaks

--------------------------------------------- JOBS ------------------------------------------------------------------

prompt
prompt JOBS
prompt ____

column what format a60 word_wrapped
column interval format a30 word_wrapped

break on job skip 1

select job, what, interval, failures, broken, schema_user
from dba_jobs;

clear breaks

--------------------------------------------- SCHEDULER ------------------------------------------------------------------

prompt
prompt SCHEDULER
prompt _________

prompt JOBS
prompt -----

set linesize 200

column interval format a30 word_wrapped
column what format a50 word_wrapped
column failures format 999
column broken format a1
column schema_user format a20
column last_date format a10
column last_sec format a10

select
  job, schema_user, what, last_date, last_sec, interval, broken, failures 
from
  dba_jobs
order by 
  job
;

prompt
prompt
prompt DEFINED SCHEDULER JOBS
prompt -----------------------

set linesize 150
column owner format a15
column state format a10
column failure_count format 999 heading FC
column run_count format 99999 heading RC
column job_name format a28
column next_run_date format a35
column last_start_date format a35

select
  owner, job_name, state, run_count, failure_count, 
  to_char(last_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') last_start_date, 
  to_char(next_run_date, 'DD/MM/YYYY HH24:MI:SS TZR') next_run_date
from
  dba_scheduler_jobs
order by
  owner, job_name
;

prompt
prompt
prompt LAST 10 RUNS PER SCHEDULER JOB
prompt -------------------------------

clear breaks
set linesize 150
column log_date format a20
column req_start_date format a35
column actual_start_date format a35
column run_duration format a14
column status format a10
column owner format a15
column job_name format a28
break on owner skip 1 on job_name skip 1

select
  owner, job_name, -- to_char(log_date, 'DD/MM/YYYY HH24:MI:SS') log_date, 
  to_char(req_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') req_start_date, 
  to_char(actual_start_date, 'DD/MM/YYYY HH24:MI:SS TZR') actual_start_date, 
  run_duration, status
from 
  ( select
      owner, job_name, log_date, req_start_date, actual_start_date, 
      run_duration, status,
      row_number () over
        ( partition by owner, job_name
          order by log_date desc
        ) rn
    from
      dba_scheduler_job_run_details
    where
      job_name not like 'ORA$AT_%' -- filter out autotasks
  ) jrd
where
  rn <= 10      
order by 
  owner, job_name, jrd.log_date desc
;

prompt
prompt
prompt 10 MOST RECENT JOB RUNS
prompt ------------------------

clear breaks
set linesize 150
column start_date format a20
column run_duration format a14
column status format a10
column owner format a15
column job_name format a30

select
  to_char(actual_start_date, 'DD/MM/YYYY HH24:MI:SS') start_date,
  owner, job_name, run_duration, status
from 
  ( select 
      actual_start_date, owner, job_name, run_duration, status
    from
      dba_scheduler_job_run_details
    where
      job_name not like 'ORA$AT_%' -- filter out autotasks
    order by 
      actual_start_date desc
  ) jrd
where
  rownum <= 10
;

prompt
prompt
prompt DEFINED AUTOTASKS
prompt ------------------

clear breaks
column client_name format a35

select
  client_name, status 
from
  dba_autotask_operation 
order by
  client_name
;

prompt
prompt
prompt AUTOTASK WINDOWS
prompt -----------------

clear breaks
set linesize 150
column window_next_time format a45

select
  * 
from
  dba_autotask_window_clients
;

prompt
prompt
prompt LAST 10 RUNS PER AUTOTASK
prompt --------------------------

column client_name format a35
column job_duration format a14
column job_start_time format a45
column job_status format a10

break on client_name skip 1

select
  client_name, job_start_time, job_duration, job_status, job_error
from
  ( select
      client_name, job_status, job_start_time, job_duration, job_error,
      row_number () over
        ( partition by client_name
          order by job_start_time desc
        ) rn
    from
      dba_autotask_job_history 
  )
where
  rn <= 10
order by 
  client_name, job_start_time desc
;

clear breaks


--------------------------------------------- THE END ------------------------------------------------------------------     
spool off

