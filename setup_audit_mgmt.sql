-- setup the maintanance of the audit logs using the dbms_audit_mgmt package
-- a purge_audit_logs job is created which uses the dbms_audit_mgmt to purge the audit records from both the db as the os that are older then 31 days
-- the job is scheduled to run each day at 21:00 hours
-- The purge procedure and scheduled job will be created under a new auditmgmt user (which will be locked and password expired)
--
-- The script needs to be executed as a dba user
--
-- interesting views are:
--   DBA_AUDIT_MGMT_CLEAN_EVENTS
--   DBA_AUDIT_MGMT_CONFIG_PARAMS
--   DBA_AUDIT_MGMT_LAST_ARCH_TS
--
-- also check MOS Note 2068066.1 - "Cleaning of FGA or Unified Audit Trail Records Not Working in 12C"
 
set serveroutput on
set heading on
set tab off
set pages 50000
set linesize 300
set trimspool on
 
 
/*
 
-- change the tablespace holding the standard and the fine grained audit trail
BEGIN
 
  dbms_audit_mgmt.set_audit_trail_location
    ( audit_trail_type            =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
      audit_trail_location_value  => 'ORAAUDIT'
    );
 
END;
/
 
*/
 
 
--- Report current settings and initialize the cleanup
 
-- report the current parameters
column parameter_name format a30
column parameter_value format a20
column audit_trail format a20
 
break on con_id skip page
 
select
  con_id,
  audit_trail,
  parameter_name,
  parameter_value
from
  cdb_audit_mgmt_config_params
order by
  con_id,
  audit_trail,
  parameter_name
;
 
clear breaks
 
-- Set the initial cleanup of the audit trails (standard, fine grained, OS and XML)
BEGIN
 
  dbms_audit_mgmt.init_cleanup
  ( audit_trail_type            =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
    default_cleanup_interval    =>  24,
    container                   =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
  );
 
  dbms_audit_mgmt.init_cleanup
  ( audit_trail_type            =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_FILES,
    default_cleanup_interval    =>  24,
    container                   =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
  );
 
END;
/
 
-- report on the parameters again
column parameter_name format a30
column parameter_value format a20
column audit_trail format a20
 
break on con_id skip page
 
select
  con_id,
  audit_trail,
  parameter_name,
  parameter_value
from
  cdb_audit_mgmt_config_params
order by
  con_id,
  audit_trail,
  parameter_name
;
 
clear breaks
 
 
 
-- setup a user that will hold the procedure and job that will progress the last archived timestamp
 
create user c##auditmgmt
identified by "welcome24Here!?"
password expire
account lock
/
 
grant execute on dbms_audit_mgmt to c##auditmgmt;
grant audit_admin to c##auditmgmt;
grant select on sys.gv_$instance to c##auditmgmt;
 
 
--- create the procedure to set the archival timestamp and perform the purging
 
-- this procedure will progress the last archived timestamp for all audit records and purge the records older then that timestamp
-- The p_retention input parameter is used to determine how many days of audit records must be kept
 
create or replace procedure
c##auditmgmt.purge_audit_logs
  ( p_retention       in    number default 180 ,  --general number of days that the audit traces must be kept
    p_std_retention   in    number default NULL,  --number of days that the audit records in the standard audit table must be kept. overrides p_retention
    p_fga_retention   in    number default NULL,  --number of days that the audit records in the fine grained audit table must be kept. overrides p_retention
    p_os_retention    in    number default NULL,  --number of days that the os audit records must be kept. overrides p_retention
    p_xml_retention   in    number default NULL   --number of days that the xml audit records must be kept. overrides p_retention
  )
 
as
 
begin
 
  -- set the last archived timestamp for the standard audit trail
  dbms_audit_mgmt.set_last_archive_timestamp
    ( audit_trail_type    =>  dbms_audit_mgmt.audit_trail_aud_std,
      last_archive_time   =>  systimestamp - nvl(p_std_retention, p_retention),
      container           =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
    );
 
  -- set the last archived timestamp for the fine grained audit trail
  dbms_audit_mgmt.set_last_archive_timestamp
    ( audit_trail_type    =>  dbms_audit_mgmt.audit_trail_fga_std,
      last_archive_time   =>  systimestamp - nvl(p_fga_retention, p_retention),
      container           =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
    );
 
  -- set the last archived timestamp for the unified grained audit trail
  dbms_audit_mgmt.set_last_archive_timestamp
    ( audit_trail_type    =>  dbms_audit_mgmt.audit_trail_unified,
      last_archive_time   =>  systimestamp - nvl(p_fga_retention, p_retention),
      container           =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
    );
 
  -- set the last archived timestamp for the os audit records on each of the instances
  for r_inst in
    ( select
        inst_id
      from
        gv$instance
    )
  loop
 
    -- for the normal os audit records
    dbms_audit_mgmt.set_last_archive_timestamp
      ( audit_trail_type    =>  dbms_audit_mgmt.audit_trail_os,
        last_archive_time   =>  systimestamp - nvl(p_os_retention, p_retention),
        rac_instance_number =>  r_inst.inst_id,
        container           =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
      );
 
    -- for the xml audit records
    dbms_audit_mgmt.set_last_archive_timestamp
      ( audit_trail_type    =>  dbms_audit_mgmt.audit_trail_xml,
        last_archive_time   =>  systimestamp - nvl(p_xml_retention, p_retention),
        rac_instance_number =>  r_inst.inst_id,
        container           =>  DBMS_AUDIT_MGMT.CONTAINER_ALL
      );
 
  end loop;
 
  -- do the actual cleaning on all audit trails
  dbms_audit_mgmt.clean_audit_trail
    ( audit_trail_type        => dbms_audit_mgmt.audit_trail_all,
      use_last_arch_timestamp => TRUE,
      container               => DBMS_AUDIT_MGMT.CONTAINER_ALL
    );
 
 
end purge_audit_logs;
/
 
 
 
--- create the job to execute the daily purge
 
BEGIN
 
  dbms_scheduler.create_job
    ( job_name        => 'c##auditmgmt.purge_audit',
      job_type        => 'PLSQL_BLOCK',
      job_action      => 'BEGIN c##auditmgmt.purge_audit_logs(31); END;',
      start_date      => to_timestamp_tz(to_char(systimestamp, 'DDMMYYYY HH24:MI:SS') || ' Europe/Brussels', 'DDMMYYYY HH24:MI:SS TZR'),
      repeat_interval => 'freq=daily; byhour=21; byminute=0; bysecond=0;',
      end_date        => NULL,
      enabled         => TRUE
  );
 
END;
/

