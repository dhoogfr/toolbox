set linesize 150
set pagesize 9999
set echo off
set verify off

column undo_retention_time format a20

select
  inst_id, 
  value undo_retention_time
from
  gv$parameter
where
  name = 'undo_retention'
order by
  inst_id
;


column undo_space format 999G999G999D99
column max_undo_space format 999G999G999D99
column undo_tbs format a15
column q_length format a12
column tu_length format a12

select
  tablespace_name, 
  sum(bytes)/1024/1024 undo_space, 
  sum(maxbytes)/1024/1024 max_undo_space,
  max(autoextensible)
from
  dba_data_files
where 
  tablespace_name in (select value from gv$parameter where name = 'undo_tablespace')
group by 
  tablespace_name
order by
  tablespace_name
;

column begin_time format a17
column end_time format a17
column retention_undo_usage format 9G999G999D99 heading "Undo ret period"
column curr_undo_usage format 9G999D99 heading "undo usage"
column pct_used format 999D99
column ts_ss format 99D99
column err format a12
column maxqueryid format a15
column inst_id format 999 

prompt err: unxpblkreucnt / ssolderrcnt / nospaceerrcnt

break on inst_id skip 1

select
  inst_id, 
  to_char(begin_time,'DD/MM/YYYY HH24:MI') begin_time, 
  to_char(end_time,'DD/MM/YYYY HH24:MI') end_time,
  ( select
      name
    from
      v$tablespace
    where
      ts# = undotsn
  ) undo_tbs, 
  curr_undo_usage, 
  retention_undo_usage,
  (100 * retention_undo_usage / (select sum(greatest(bytes,maxbytes))/1024/1024 from dba_data_files where tablespace_name = (select name from v$tablespace where ts# = undotsn))) pct_used,
  ts_dd || ' ' || ts_hh || ':' || ts_mi || ':' || ts_ss q_length,
  tund_dd || ' ' || tund_hh || ':' || tund_mi || ':' || tund_ss tu_length,
  maxqueryid,
  err
from 
  ( select
      inst_id,
      undotsn,
      begin_time,
      end_time, 
      undoblks * (select block_size from dba_tablespaces where tablespace_name = (select name from v$tablespace where ts# = undotsn)) /1024/1024 curr_undo_usage,
      ((activeblks + unexpiredblks) * (select block_size from dba_tablespaces where tablespace_name = (select name from v$tablespace where ts# = undotsn)) /1024/1024) retention_undo_usage,
      decode(maxquerylen, 0, 0, extract(day from (systimestamp + numtodsinterval(maxquerylen,'second') - systimestamp))) ts_dd,
      decode(maxquerylen, 0, 0, extract(hour from (systimestamp + numtodsinterval(maxquerylen,'second') - systimestamp))) ts_hh,
      decode(maxquerylen, 0, 0, extract(minute from (systimestamp + numtodsinterval(maxquerylen,'second') - systimestamp))) ts_mi,
      decode(maxquerylen, 0, 0, floor(extract(second from (systimestamp + numtodsinterval(maxquerylen,'second') - systimestamp)))) ts_ss,
      decode(tuned_undoretention, 0, 0, extract(day from (systimestamp + numtodsinterval(tuned_undoretention,'second') - systimestamp))) tund_dd,
      decode(tuned_undoretention, 0, 0, extract(hour from (systimestamp + numtodsinterval(tuned_undoretention,'second') - systimestamp))) tund_hh,
      decode(tuned_undoretention, 0, 0, extract(minute from (systimestamp + numtodsinterval(tuned_undoretention,'second') - systimestamp))) tund_mi,
      decode(tuned_undoretention, 0, 0, floor(extract(second from (systimestamp + numtodsinterval(tuned_undoretention,'second') - systimestamp)))) tund_ss,
      maxqueryid, 
      unxpblkreucnt || '/' || ssolderrcnt  || '/' || nospaceerrcnt err
    from 
      gv$undostat 
  ) U
where
  begin_time >= sysdate -1
  and end_time <= sysdate
order by
  inst_id, 
  U.begin_time
;

clear breaks
