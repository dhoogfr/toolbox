set linesize 500
set pagesize 9999
alter session set nls_numeric_characters=',.';
set trimspool on
set tab off
set verify off
set feedback off

column instance_number format 99
column bsnap_id format 9999999
column bsnap_time format a16
column esnap_id format 9999999
column esnap_time format a16

column phy_read_total_bytes format 9G999G999G999
column phy_read_bytes format 9G999G999G999
column phy_write_total_bytes format 9G999G999G999
column phy_write_bytes  format 9G999G999G999

column phy_read_total_mb format 999G999D99
column phy_read_mb format 999G999D99
column phy_write_total_mb format 999G999D99
column phy_write_mb format 999G999D99
column phy_io_total_mb format 999G999D99
column phy_io_mb format 999G999D99

WITH p as
 ( select dbid, instance_number, snap_id,
          lag(snap_id, 1, snap_id) over
            ( partition by dbid, instance_number
              order by snap_id
            ) prev_snap_id,
          begin_interval_time, end_interval_time
   from dba_hist_snapshot
   where begin_interval_time between
            to_timestamp ('01/10/2019 00:00', 'DD/MM/YYYY HH24:MI')
            and to_timestamp ('15/10/2019 00:00', 'DD/MM/YYYY HH24:MI')
 ),
 s as
 ( select d.name database, p.dbid, p.instance_number, p.prev_snap_id bsnap_id, p.snap_id esnap_id,
          p.begin_interval_time bsnap_time, p.end_interval_time esnap_time, bs.stat_name,
          round((es.value-bs.value)/(   extract(second from (p.end_interval_time - p.begin_interval_time))
                                      + extract(minute from (p.end_interval_time - p.begin_interval_time)) * 60
                                      + extract(hour   from (p.end_interval_time - p.begin_interval_time)) * 60 * 60
                                      + extract(day    from (p.end_interval_time - p.begin_interval_time)) * 24 * 60 * 60
                                    )
                ,6
               ) valuepersecond
   from v$database d, p,
        dba_hist_sysstat bs, dba_hist_sysstat es
   where d.dbid = p.dbid
         and ( p.dbid = bs.dbid
               and p.instance_number = bs.instance_number
               and p.prev_snap_id = bs.snap_id
             )
         and ( p.dbid = es.dbid
               and p.instance_number = es.instance_number
               and p.snap_id = es.snap_id
             )
         and ( bs.stat_id = es.stat_id
               and bs.instance_number = es.instance_number
               and bs.stat_name=es.stat_name
             )
         and bs.stat_name in
           ( 'physical read total bytes','physical read bytes','physical write total bytes','physical write bytes')
 ),
g as
 ( select /*+ FIRST_ROWS */
          database, instance_number,  bsnap_id, esnap_id, bsnap_time, esnap_time,
          sum(decode( stat_name, 'physical read total bytes'               , valuepersecond, 0 )) phy_read_total_bytes,
          sum(decode( stat_name, 'physical read bytes'                     , valuepersecond, 0 )) phy_read_bytes,
          sum(decode( stat_name, 'physical write total bytes'              , valuepersecond, 0 )) phy_write_total_bytes,
          sum(decode( stat_name, 'physical write bytes'                    , valuepersecond, 0 )) phy_write_bytes
 from s
 group by database,instance_number, bsnap_id, esnap_id, bsnap_time, esnap_time
 )
select instance_number, bsnap_id, to_char(bsnap_time,'DD-MON-YY HH24:MI') bsnap_time_str, esnap_id, to_char(esnap_time,'DD-MON-YY HH24:MI') esnap_time_str,
        phy_read_total_bytes/1024/1024 phy_read_total_mb, 
        phy_read_bytes/1024/1024 phy_read_mb, 
        phy_write_total_bytes/1024/1024 phy_write_total_mb, 
        phy_write_bytes/1024/1024 phy_write_mb,
        (phy_read_total_bytes + phy_write_total_bytes) /1024/1024 phy_io_total_mb,
        (phy_read_bytes + phy_write_bytes) /1024/1024 phy_io_mb
from g
order by instance_number, bsnap_time;
