-- list all available backupsets with summations per report, device type, (unique) database and backupjob session
-- this query can be used to give a good idea about the active size of the backups (either on tape or on disk)
-- note that this does not take in account any compression or deduplication (or duplication for that matter) done by the storage or backup software
-- There is grouping done on the backup pieces to combine the output of multiple sessions / pieces to limit the output but keep track of the different stages of the backups
-- The report shows for instance different lines within 1 backup session for the backup archive logs, backup of the database, backup of the new archivelogs and finally backup of the controlfile, but
-- it would not show seperate lines for each of the backup pieces or channels
--
-- The elapsed time reflects the wall clock time, but can be misleading as a for instance part of the backup is no longer available 
-- (eg archivelog backups before and after a db backup are available, but the db backup itself not, in which case the time spend on the db backup would still be included in the archivelog backup)

-- This query needs to run against the rman repository catalog



set linesize 300
set pages 50000

column db_id format 9999999999999
column name format a8
column db_unique_name format a15
column device_type format a10
column subjob_mb format 999G999G999D99
column elapsed_time format a12
column subjob_start_time format a16
column subjob_end_time format a16

break on device_type skip page on dbid on name skip 1 on db_unique_name on session_key skip 1 on report

compute sum of subjob_mb on session_key
compute sum of subjob_mb on db_unique_name
compute sum of subjob_mb on device_type
compute sum of subjob_mb on report

with available_bs as
( select
    distinct
    db_key,
    site_key,
    session_key,
    ( case backup_type
        when 'D' then 'Full'
        when 'L' then 'Logfile'
        when 'I' then 'Incremental'
      end
    ) as long_backup_type,
    incremental_level,
    device_type,
    subjob_start_time,
    subjob_completion_time,
--    subjob_elapsed_sec,
    ((subjob_completion_time - subjob_start_time) * 24 * 60 * 60) subjob_elapsed_sec,
    subjob_bytes/1024/1024 subjob_mb
  from
    ( select
        db_key,
        site_key,
        session_key,
        backup_type,
        incremental_level,
        device_type,
        min(start_time) over (partition by session_key, backup_type, change_grp) subjob_start_time,
        max(completion_time) over (partition by session_key, backup_type, change_grp) subjob_completion_time,
--        sum(elapsed_seconds) over (partition by session_key, backup_type, change_grp) subjob_elapsed_sec,
        sum(bytes) over (partition by session_key, backup_type, change_grp) subjob_bytes
      from
        ( select
            db_key,
            site_key,
            session_key,
            backup_type,
            incremental_level,
            device_type,
            start_time,
            completion_time,
--            elapsed_seconds,
            bytes,
            -- create a running total of the change marks, which gives a grouping
            -- as the change mark is 0 when the backup type does not change, the total only increases when the backup type has changed between 2 subsequent records
            -- this grouping id can now be used to split a group when the backup type has changed in between
            sum(change_mark) over (partition by session_key, backup_type order by start_time) change_grp
          from 
            ( select
                db_key,
                site_key,
                session_key,
                backup_type,
                incremental_level,
                device_type,
                start_time,
                completion_time,
--                elapsed_seconds,
                bytes,
                -- mark where the backup type changes with a 1, when the backup type does not change set the value to 0
                (case when backup_type = (lag(backup_type) over (partition by session_key order by start_time)) then 0 else 1 end) as change_mark
              from
                rc_backup_piece_details
            )
        )
    )
)
select
  abs.device_type,
  db.dbid,
  db.name,
  st.db_unique_name,
  abs.session_key,
  to_char(abs.subjob_start_time, 'DD/MM/YYYY HH24:MI') subjob_start_time,
  to_char(abs.subjob_completion_time, 'DD/MM/YYYY HH24:MI') subjob_end_time,
  ( decode(abs.subjob_elapsed_sec, 0, 0, extract(day from (systimestamp + numtodsinterval(abs.subjob_elapsed_sec,'second') - systimestamp))) || ' ' ||
    decode(abs.subjob_elapsed_sec, 0, 0, extract(hour from (systimestamp + numtodsinterval(abs.subjob_elapsed_sec,'second') - systimestamp))) || ':' ||
    decode(abs.subjob_elapsed_sec, 0, 0, extract(minute from (systimestamp + numtodsinterval(abs.subjob_elapsed_sec,'second') - systimestamp))) || ':' ||
    decode(abs.subjob_elapsed_sec, 0, 0, floor(extract(second from (systimestamp + numtodsinterval(abs.subjob_elapsed_sec,'second') - systimestamp))))
  ) as elapsed_time,
  abs.long_backup_type,
  abs.incremental_level,
  abs.subjob_mb
from
  available_bs  abs,
  rc_site       st,
  rc_database   db
where
  abs.site_key = st.site_key
  and db.db_key = abs.db_key
order by
  abs.device_type,
  db.dbid,
  db.name,
  st.db_unique_name,
  abs.subjob_start_time,
  long_backup_type
;

clear breaks;
clear computes;
