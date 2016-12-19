-- TOEVOEGEN AVG READ TIME VOOR SINGLE BLOCK READS EN MULTIBLOCK READS

set linesize 300
set pages 50000

column snap_time format a20
column instance_number format 99 heading IN
column snap_id format 99999 heading ID
column tsname format a25

column phyrds format 99G999G999G999
column phywrts format 99G999G999G999
column singleblkrds format 99G999G999G999
column readtim_hs format 99G999G999G999
column writetim_hs format 99G999G999G999
column singleblkrdtim_hs format 99G999G999G999
column avg_singleblkrdtim_ms format 999G990D99
column phyblkrd format 99G999G999G999
column phyblkwrt format 99G999G999G999
column wait_count format 99G999 heading wc
column wait_time format 999G999 heading wt


break on snap_time skip page on snap_id on tsname skip 1 on file#

with snap as
 ( select
      dbid,
      instance_number,
      snap_id,
      lag(snap_id, 1, snap_id) over
        ( partition by dbid, instance_number
          order by snap_id
        ) prev_snap_id,
      begin_interval_time,
      end_interval_time
   from
    dba_hist_snapshot
   where
    begin_interval_time between
      systimestamp -1
      and systimestamp
 )
select
  to_char(snap.end_interval_time, 'DD/MM/YYYY HH24:MI:SS') snap_time,
  snap.snap_id,
  state.tsname,
  state.file#,
  snap.instance_number,
  (state.phyrds - statb.phyrds) phyrds,
  (state.phywrts - statb.phywrts) phywrts,
  (state.singleblkrds - statb.singleblkrds) singleblkrds,
  (state.readtim - statb.readtim) readtim_hs,
  (state.writetim - statb.writetim) writetim_hs,
  (state.singleblkrdtim - statb.singleblkrdtim) singleblkrdtim_hs,
  ((state.singleblkrdtim - statb.singleblkrdtim) /  greatest((state.singleblkrds - statb.singleblkrds),1) * 10) avg_singleblkrdtim_ms,
  (state.phyblkrd - statb.phyblkrd) phyblkrd,
  (state.phyblkwrt - statb.phyblkwrt) phyblkwrt,
  (state.wait_count - statb.wait_count) wait_count,
  (state.time - statb.time) wait_time
from
  snap,
  dba_hist_filestatxs statb,
  dba_hist_filestatxs state
where
  snap.dbid = state.dbid
  and snap.instance_number = state.instance_number
  and snap.snap_id = state.snap_id
  and snap.dbid = statb.dbid
  and snap.instance_number = statb.instance_number
  and snap.prev_snap_id = statb.snap_id
  and statb.file# = state.file#
order by
  snap.dbid,
  snap_time,
  snap.snap_id,
  state.tsname,
  state.file#,
  snap.instance_number
;

clear breaks
