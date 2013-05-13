set verify off

select
  site.db_unique_name,
  db.dbid,
  rs.session_key,
  to_char(rs.start_time, 'DD/MM/YYYY HH24:MI:SS') s_start_time,
  to_char(rs.end_time, 'DD/MM/YYYY HH24:MI:SS') s_end_time,
  rs.status,
  rs.object_type,
  rs.input_bytes/1024/1024 mb_in,
  rs.output_bytes/1024/1024 mb_out,
  rs.output_device_type
from
  rc_rman_status  rs,
  rc_site         site,
  rc_database     db
where
  rs.site_key = site.site_key
  and rs.db_key = db.db_key
  and rs.session_key in 
    ( select
        session_key
      from
        rc_rman_status
      where
        operation = 'BACKUP'
    )
  and rs.session_key in
    ( select
        session_key
      from
        rc_rman_status
      where
        operation = 'RMAN'
        and start_time > sysdate -1
    )
order by
  db_unique_name,
  session_key,
  row_level,
  start_time
;


set linesize 300
column object_type format a15
column row_type format a10
column db_unique_name format a15
column status format a25
column mb_in format 999G999G999
column mb_out format 999G999G999

break on db_unique_name skip 2 on dbid on session_key skip 1

select
  site.db_unique_name,
  db.dbid,
  rs.session_key,
  rs.row_type,
  rs.row_level,
  to_char(rs.start_time, 'DD/MM/YYYY HH24:MI:SS') s_start_time,
  to_char(rs.end_time, 'DD/MM/YYYY HH24:MI:SS') s_end_time,
  rs.operation,
  rs.status,
  rs.object_type,
from
  rc_rman_status  rs,
  rc_site         site,
  rc_database     db
where
  rs.site_key = site.site_key
  and rs.db_key = db.db_key
  and rs.session_key in 
    ( select
        session_key
      from
        rc_rman_status
      where
        operation = 'BACKUP'
    )
  and rs.session_key in
    ( select
        session_key
      from
        rc_rman_status
      where
        operation = 'RMAN'
        and start_time > sysdate -1
    )
order by
  db_unique_name,
  session_key,
  row_level,
  start_time
;

clear breaks

accept l_session_key prompt "Enter Session key: "

select
  output
from
  rc_rman_output
where
  session_key = 2257774
;
