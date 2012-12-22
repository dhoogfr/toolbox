with backup_set_details
as
( select set_count, set_stamp, session_recid, session_stamp
  from v$backup_set_details
  group by set_count, set_stamp, set_count, session_recid, session_stamp
)
select rbjd.session_key, rbjd.session_stamp, bs.set_stamp, bs.set_count, bs.backup_type, bs.incremental_level, bs.start_time, 
       bs.completion_time, bs.elapsed_seconds, bp.piece#, bp.status, bp.start_time, 
       bp.completion_time, bp.elapsed_seconds, bp.deleted, bp.bytes/1024/1024 mb, bp.compressed
from v$backup_set bs, v$backup_piece bp, backup_set_details bsd, v$rman_backup_job_details rbjd
where bs.set_stamp = bp.set_stamp
      and bs.set_count = bp.set_count
      and bs.set_stamp = bsd.set_stamp
      and bs.set_count = bsd.set_count
      and bsd.session_recid = rbjd.session_recid
      and bsd.session_stamp = rbjd.session_stamp
      and bp.status != 'D'
order by bs.start_time, bp.piece#;


