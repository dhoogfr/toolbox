set linesize 200
set pages 50000

column bundle_series format a15
column action_time format a30
column version format a12
column description format a60

select patch_id, version, action, status, action_time, bundle_series, description from dba_registry_sqlpatch order by action_time desc;

select con_id, con_uid, name, open_mode, open_time from v$pdbs;