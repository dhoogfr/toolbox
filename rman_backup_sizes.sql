column mb format 999G999G999D99
column backup_job format a20
column backup_type format a10 heading TYPE
column start_time format a25
column end_time format a25
column incremental_level format 999 heading IL
compute sum of mb on backup_job 
compute sum of mb on report

break on backup_job skip 1 on start_time on end_time on report

with backup_set_details
as
( select
    distinct
    set_count, set_stamp, session_recid, session_stamp, backup_type, incremental_level, compressed
  from
    v$backup_set_details
)
select
  rbjd.session_key || ',' || rbjd.session_stamp         backup_job, 
  to_char(rbjd.start_time, 'DY DD/MM/YYYY HH24:MI:SS')  start_time, 
  to_char(rbjd.end_time, 'DY DD/MM/YYYY HH24:MI:SS')    end_time, 
  decode(bsd.backup_type,'L','ARCHIVE', 'DATA')         backup_type,
  bsd.incremental_level,
  bsd.compressed,
  sum(bp.bytes)/1024/1024                               mb
from
  v$backup_piece                bp, 
  backup_set_details            bsd, 
  v$rman_backup_job_details     rbjd
where
  bsd.set_stamp = bp.set_stamp
  and bsd.set_count = bp.set_count
  and bsd.session_recid = rbjd.session_recid
  and bsd.session_stamp = rbjd.session_stamp
  and bp.status != 'D'
group by
  rbjd.session_key, 
  rbjd.session_stamp, 
  rbjd.start_time, 
  rbjd.end_time,
  decode(bsd.backup_type,'L','ARCHIVE', 'DATA'),
  bsd.incremental_level,
  bsd.compressed
order by
  rbjd.start_time;
