clear breaks
set pagesize 9999
set serveroutput on
set trimspool on
set echo off
set feedback 1

----------------------------------------- either specify a logfile name yourself or one will be generated for you

set verify off
set feedback off
column dcol new_value spoolname noprint
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;

select
  nvl('&1', db_unique_name || '_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '_db_overview.log') dcol
from
  v$database
;

undefine 1

spool &spoolname

prompt version and os info
prompt ...................


select * from v$version;
@list_db_patches.sql
select * from v$osstat order by stat_name;


prompt tablespace and datafiles details
prompt ................................

@db_size2.sql
@tbs_info.sql
@df_details2.sql

@online_logfiles_info.sql
@fra_usage.sql


prompt ASM layout
prompt ..........

@asm_diskgroup_info.sql
@dg_attributes.sql


prompt DB Config
prompt .........

@list_parameters2.sql
@list_arch_dest.sql
@sga_report.sql
@db_cache_advice.sql


prompt DB Jobs
prompt .......

@get_job_overview.sql
@show_autotasks.sql


prompt RMAN backups
prompt ............

@rman_backup_overview2.sql


prompt Some load info
prompt ..............

@archived_redo_stats.sql
@undo_usage_24window.sql
@top_segments_size.sql
set linesize 300
@top_seg_history.sql
@tblspace_growth.sql

spool off;
