set linesize 200

column bjob format a15
column recid format 99999
column start_time format a20
column handle format a55
column mb format 9G999G999D99
column media format a15

break on bjob skip 1 on recid on backup_type on start_time

compute sum of mb on bjob

with backup_set_details
as
( select set_count, set_stamp, session_recid, session_stamp
  from v$backup_set_details
  group by set_count, set_stamp, set_count, session_recid, session_stamp
)
select rbjd.session_recid ||',' || rbjd.session_stamp bjob, bs.recid recid, bs.backup_type, 
       to_char(bs.start_time, 'DD/MM/YYYY HH24:MI:SS') start_time, 
       bp.piece#, bp.bytes/1024/1024 mb, bp.compressed, bp.handle, bp.media
from v$backup_set bs, v$backup_piece bp, backup_set_details bsd, v$rman_backup_job_details rbjd
where bs.set_stamp = bp.set_stamp
      and bs.set_count = bp.set_count
      and bs.recid = bsd.recid
      and bs.stamp = bsd.stamp
      and bsd.session_recid = rbjd.session_recid
      and bsd.session_stamp = rbjd.session_stamp
      and bp.status != 'D'
order by bjob, bs.start_time, bs.recid, bp.piece#;
