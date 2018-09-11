set linesize 200

column username format a30
column created format a10
column lock_date format a10
column expiry_date format a10
column profile format a20
column account_status format a25
column default_tablespace format a20
column temporary_tablespace format a20
column initial_rsrc_consumer_group format a30

select
  username,
  to_char(created, 'DD/MM/YYYY') created,
  profile,
  account_status,
  to_char(lock_date,'DD/MM/YYYY') lock_date,
  to_char(expiry_date,'DD/MM/YYYY') expiry_date,
  default_tablespace,
  temporary_tablespace,
  initial_rsrc_consumer_group
from
  dba_users
where
  expiry_date is not null
  and username not in
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
      'AUTHENTICATEDUSER','JMXSERVER','OLAPSYS'
    )
order by
  username
;
