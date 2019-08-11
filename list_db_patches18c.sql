set linesize 250
column name format a15
column patch_type format a15
column status format a15
column description format a65
column action_time format a20

break on name skip page

select
  con.name,
  to_char(sqlp.action_time, 'DD/MM/YYYY HH24:MI') action_time_str,
  sqlp.action,
  sqlp.patch_type,
  sqlp.patch_id,
  sqlp.patch_uid,
  sqlp.source_version,
  sqlp.target_version,
  sqlp.status,
  sqlp.description
from
  cdb_registry_sqlpatch sqlp
    left outer join v$containers con
      on ( sqlp.con_id = con.con_id )
order by
  con.name,
  action_time,
  patch_type,
  patch_id
;

clear breaks
