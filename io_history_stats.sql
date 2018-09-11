set linesize 200

column snap_time format a20
column instance_number format 99 heading IN
column snap_id format 99999 heading ID
column tsname format a10
column wait_count format 99999 heading WC
column time format 999999

break on instance_number skip 2 on snap_time skip 1 on snap_id

select to_char(snap.begin_interval_time, 'DD/MM/YYYY HH24:MI:SS') snap_time, 
       snap.instance_number, snap.snap_id,
       stat.tsname, stat.file#, stat.block_size, stat.phyrds, stat.phywrts, 
       stat.singleblkrds, stat.readtim, stat.writetim, stat.singleblkrdtim, 
       stat.phyblkrd, stat.phyblkwrt, stat.wait_count, stat.time
from dba_hist_snapshot snap, dba_hist_filestatxs stat
where snap.snap_id = stat.snap_id
      and snap.instance_number = stat.instance_number
      and snap.dbid = stat.dbid
      and begin_interval_time between 
            to_timestamp('15/10/2008 00:00', 'DD/MM/YYYY HH24:MI')
            and to_timestamp('15/10/2008 12:00', 'DD/MM/YYYY HH24:MI')
order by snap.dbid, snap.instance_number, snap.snap_id;
