set serveroutput on
set timing on

DECLARE

  l_actual_latency    integer;
  l_max_iops          integer;
  l_max_mbps          integer;

BEGIN

  dbms_resource_manager.calibrate_io 
    ( num_physical_disks  =>  30, 
      max_latency         =>  15, 
      max_iops            =>  l_max_iops, 
      max_mbps            =>  l_max_mbps, 
      actual_latency      =>  l_actual_latency
    );
 
  dbms_output.put_line ('max_iops = ' || l_max_iops);
  dbms_output.put_line ('actual_latency  = ' || l_actual_latency);
  dbms_output.put_line('max_mbps = ' || l_max_mbps);

END;
/


select * from gv$io_calibration_status;

set linesize 150
column start_time format a30
column end_time format a30
column num_physical_disks format 9999 heading NPD
select * from dba_rsrc_io_calibrate;
