set linesize 150
set pages 9999

column destination format a40
column status format a15
column valid_now format a10
column dest_id heading ID format 99
column process heading RPROC format a5
column archiver heading LPROC format a5
--column lc format 99
--column la format 99
column dm format 9999
column valid_type heading VT format a2
column valid_role heading VR format a2
column valid_now format a10
column seq# format 999999999

select lad.dest_id, lad.status, lad.destination, lad.archiver, lad.process, las.recovery_mode, 
       lad.schedule, 
       decode(valid_type, 'ONLINE_LOGFILE', 'OL', 
                          'STANDBY_LOGFILE', 'SL',
                          'ALL_LOGFILES', 'AL',
                          valid_type
             ) valid_type, 
       decode(valid_role, 'PRIMARY_ROLE', 'PR',
                          'STANDBY_ROLE', 'SR',
                          'ALL_ROLES', 'AR',
                          valid_role
             ) valid_role, 
       valid_now, lad.delay_mins dm, lad.log_sequence seq#
--       ,las.standby_logfile_count lc, las.standby_logfile_active la
from v$archive_dest lad, v$archive_dest_status las
where lad.dest_id = las.dest_id
      and lad.destination is not null
order by lad.dest_id;
