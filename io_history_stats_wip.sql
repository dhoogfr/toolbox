-- TOEVOEGEN AVG READ TIME VOOR SINGLE BLOCK READS EN MULTIBLOCK READS

set linesize 200
set pages 50000

column snap_time format a20
column instance_number format 99 heading IN
column snap_id format 99999 heading ID
column tsname format a10
column wait_count format 9999999 heading WC
column time format 999999

break on instance_number skip 2 on snap_time skip 1 on snap_id on tsname

with snap as
 ( select dbid, instance_number, snap_id,
          lag(snap_id, 1, snap_id) over
            ( partition by dbid, instance_number
              order by snap_id
            ) prev_snap_id,
          begin_interval_time, end_interval_time          
   from dba_hist_snapshot
   where begin_interval_time between
            to_timestamp('20/10/2008 00:00', 'DD/MM/YYYY HH24:MI')
            and to_timestamp('29/10/2008 12:00', 'DD/MM/YYYY HH24:MI')
 ) 
select to_char(snap.end_interval_time, 'DD/MM/YYYY HH24:MI:SS') snap_time, 
       snap.instance_number, snap.snap_id, state.tsname, state.file#, 
       (state.phyrds - statb.phyrds) phyrds, 
       (state.phywrts - statb.phywrts) phywrts, 
       (state.singleblkrds - statb.singleblkrds) singleblkrds, 
       (state.readtim - statb.readtim) readtim, 
       (state.writetim - statb.writetim) writetim, 
       (state.singleblkrdtim - statb.singleblkrdtim) singleblkrdtim, 
       (state.phyblkrd - statb.phyblkrd) phyblkrd,
       (state.phyblkwrt - statb.phyblkwrt) phyblkwrt, 
       (state.wait_count - statb.wait_count) wait_count, 
       (state.time - statb.time) wait_time
from snap, dba_hist_filestatxs statb, dba_hist_filestatxs state
where ( snap.dbid = state.dbid
        and snap.instance_number = state.instance_number
        and snap.snap_id = state.snap_id
      )
      and ( snap.dbid = statb.dbid
            and snap.instance_number = statb.instance_number
            and snap.prev_snap_id = statb.snap_id
           )
     and statb.file# = state.file#
order by snap.dbid, snap.instance_number, snap.snap_id, state.tsname, state.file#;

