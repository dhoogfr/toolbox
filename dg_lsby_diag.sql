--------------------------- Script begins here --------------------------- 

-- NAME: dg_lsby_diag.sql  (Run on LOGICAL STANDBY)
-- ------------------------------------------------------------------------  
--    Copyright 2002, Oracle Corporation
-- LAST UPDATED: 2/23/04
--
-- Usage: @dg_lsby_diag
-- ------------------------------------------------------------------------  
-- PURPOSE:  
--    This script is to be used to assist in collection information to help
--    troubeshoot Data Guard issues involving a Logical Standby.
-- ------------------------------------------------------------------------  
-- DISCLAIMER:  
--    This script is provided for educational purposes only. It is NOT   
--    supported by Oracle World Wide Technical Support.  
--    The script has been tested and appears to work as intended.  
--    You should always run new scripts on a test instance initially.  
-- ------------------------------------------------------------------------  
-- Script output is as follows: 
 
set echo off 
set feedback off 
column timecol new_value timestamp 
column spool_extension new_value suffix 
select to_char(sysdate,'Mondd_hhmi') timecol, 
'.out' spool_extension from sys.dual; 
column output new_value dbname 
select value || '_' output 
from v$parameter where name = 'db_name'; 
spool dg_lsby_diag_&&dbname&&timestamp&&suffix 

set linesize 79
set pagesize 180
set long 1000
set trim on 
set trims on 
alter session set nls_date_format = 'MM/DD HH24:MI:SS'; 
set feedback on 
select to_char(sysdate) time from dual; 
 
set echo on 
 
-- The following select will give us the generic information about how
-- this standby is setup.  The database_role should be logical standby as
-- that is what this script is intended to be ran on.

column ROLE format a7 tru 
column NAME format a8 wrap
select name,database_role,log_mode,protection_mode
from v$database; 

-- ARCHIVER can be (STOPPED | STARTED | FAILED). FAILED means that the
-- archiver failed to archive a log last time, but will try again within 5
-- minutes. LOG_SWITCH_WAIT The ARCHIVE LOG/CLEAR LOG/CHECKPOINT event log
-- switching is waiting for. Note that if ALTER SYSTEM SWITCH LOGFILE is
-- hung, but there is room in the current online redo log, then value is
-- NULL

column host_name format a20 tru 
column version format a9 tru 
select instance_name,host_name,version,archiver,log_switch_wait 
from v$instance; 

-- The following query give us information about catpatch.
-- This way we can tell if the procedure doesn't match the image.

select version, modified, status from dba_registry 
where comp_id = 'CATPROC';
 
-- Force logging and supplemental logging are not mandatory but are
-- recommended if you plan to switchover.  During normal operations it is
-- acceptable for SWITCHOVER_STATUS to be SESSIONS ACTIVE or NOT ALLOWED.

column force_logging format a13 tru 
column remote_archive format a14 tru 
column dataguard_broker format a16 tru 

select force_logging,remote_archive,supplemental_log_data_pk,
supplemental_log_data_ui,switchover_status,dataguard_broker 
from v$database;  
 
-- This query produces a list of all archive destinations.  It shows if
-- they are enabled, what process is servicing that destination, if the
-- destination is local or remote, and if remote what the current mount ID
-- is.

column destination format a35 wrap 
column process format a7 
column archiver format a8 
column ID format 99 
column mid format 99
 
select dest_id "ID",destination,status,target,
       schedule,process,mountid  mid
from v$archive_dest order by dest_id;
 
-- This select will give further detail on the destinations as to what
-- options have been set.  Register indicates whether or not the archived
-- redo log is registered in the remote destination control file.

set numwidth 8
column ID format 99 

select dest_id "ID",archiver,transmit_mode,affirm,async_blocks async,
       net_timeout net_time,delay_mins delay,reopen_secs reopen,
       register,binding 
from v$archive_dest order by dest_id;
  
-- Determine if any error conditions have been reached by querying the
-- v$dataguard_status view (view only available in 9.2.0 and above):

column message format a80 

select message, timestamp 
from v$dataguard_status 
where severity in ('Error','Fatal') 
order by timestamp; 
 
-- Query v$managed_standby to see the status of processes involved in
-- the shipping redo on this system.  Does not include processes needed to
-- apply redo.

select process,status,client_process,sequence#
from v$managed_standby;

-- Verify that log apply services on the standby are currently
-- running. If the query against V$LOGSTDBY returns no rows then logical
-- apply is not running.

column status format a50 wrap
column type format a11
set numwidth 15

SELECT TYPE, STATUS, HIGH_SCN               
FROM V$LOGSTDBY;

-- The DBA_LOGSTDBY_PROGRESS view describes the progress of SQL apply
-- operations on the logical standby databases.  The APPLIED_SCN indicates
-- that committed transactions at or below that SCN have been applied. The
-- NEWEST_SCN is the maximum SCN to which data could be applied if no more
-- logs were received. This is usually the MAX(NEXT_CHANGE#)-1 from
-- DBA_LOGSTDBY_LOG.  When the value of NEWEST_SCN and APPLIED_SCN are the
-- equal then all available changes have been applied.  If your
-- APPLIED_SCN is below NEWEST_SCN and is increasing then SQL apply is
-- currently processing changes.

set numwidth 15

select 
  (case 
    when newest_scn = applied_scn then 'Done'
    when newest_scn <= applied_scn + 9 then 'Done?'
    when newest_scn > (select max(next_change#) from dba_logstdby_log)
    then 'Near done'
    when (select count(*) from dba_logstdby_log 
          where (next_change#, thread#) not in 
                  (select first_change#, thread# from dba_logstdby_log)) > 1
    then 'Gap'
    when newest_scn > applied_scn then 'Not Done'
    else '---' end) "Fin?",
    newest_scn, applied_scn, read_scn from dba_logstdby_progress;

select newest_time, applied_time, read_time from dba_logstdby_progress;

-- Determine if apply is lagging behind and by how much.  Missing
-- sequence#'s in a range indicate that a gap exists.

set numwidth 15
column trd format 99

select thread# trd, sequence#,
    first_change#, next_change#,
    dict_begin beg, dict_end end, 
    to_char(timestamp, 'hh:mi:ss') timestamp,
    (case when l.next_change# < p.read_scn then 'YES'
          when l.first_change# < p.applied_scn then 'CURRENT'
          else 'NO' end) applied
 from dba_logstdby_log l, dba_logstdby_progress p
 order by thread#, first_change#;

-- Get a history on logical standby apply activity.

set numwidth 15

select to_char(event_time, 'MM/DD HH24:MI:SS') time, 
       commit_scn, current_scn, event, status 
from dba_logstdby_events
order by event_time, commit_scn, current_scn;

-- Dump logical standby stats

column name format a40
column value format a20

select * from v$logstdby_stats;

-- Dump logical standby parameters

column name format a33 wrap
column value format a33 wrap
column type format 99

select name, value, type from system.logstdby$parameters 
order by type, name;

-- Gather log miner session and dictionary information.

set numwidth 15 

select * from system.logmnr_session$;
select * from system.logmnr_dictionary$;
select * from system.logmnr_dictstate$;
select * from v$logmnr_session;

-- Query the log miner dictionary for key tables necessary to process
-- changes for logical standby Label security will move AUD$ from SYS to
-- SYSTEM.  A synonym will remain in SYS but Logical Standby does not
-- support this.

set numwidth 5
column name format a9 wrap
column owner format a6 wrap

select o.logmnr_uid, o.obj#, o.objv#, u.name owner, o.name
 from system.logmnr_obj$ o, system.logmnr_user$ u 
 where 
      o.logmnr_uid = u.logmnr_uid and 
      o.owner# = u.user# and 
      o.name in ('JOB$','JOBSEQ','SEQ$','AUD$',
                 'FGA_LOG$','IND$','COL$','LOGSTDBY$PARAMETER')
 order by u.name;

-- Non-default init parameters. 

column name format a30 tru 
column value format a48 wra 
select name, value 
from v$parameter 
where isdefault = 'FALSE';
 
spool off

--------------------------- Script ends here  --------------------------- 

