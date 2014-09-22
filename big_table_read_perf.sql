set lines 150
set pages 9999
set feedback off
set echo off

select distinct sid from v$mystat;
alter system flush buffer_cache;

alter session set "_serial_direct_read"='always';

--exec dbms_monitor.session_trace_enable(waits => true)

DECLARE

    l_cnt           number;
    l_start_value   number;
    l_end_value     number;
    l_diff          number;
    l_start         timestamp;
    l_end           timestamp;
    l_elapsed       number;
    l_throughput    number;

BEGIN

    select value
    into l_start_value
    from v$mystat mystat, v$statname statname
    where mystat.statistic# = statname.statistic#
          and statname.name = 'physical read bytes';
         
    l_start := systimestamp;

    select /*+ FULL(A) PARALLEL(A,10) */ count(*) into l_cnt from sysadm.COMLONG A;
    -- select /*+ FULL(A) NOPARALLEL(A) */ count(*) into l_cnt from sysadm.COMLONG A;
    -- select /*+ FULL(A) */ count(*) into l_cnt from c2mv5.hist_act A;

    l_end := systimestamp;

    
    select value
    into l_end_value
    from v$mystat mystat, v$statname statname
    where mystat.statistic# = statname.statistic#
          and statname.name = 'physical read bytes';   

    l_elapsed :=  extract(day from (l_end - l_start)) * 24 * 60 * 60
                  + extract(hour from (l_end - l_start)) * 60 * 60
                  + extract(minute from (l_end - l_start)) * 60
                  + extract(second from (l_end - l_start));
    l_diff := (l_end_value - l_start_value);
    l_throughput := (l_diff/l_elapsed)/1024/1024;
    
    dbms_output.put_line('physical MB read: ' || to_char(l_diff/1024/1024, '999G999G999D99'));
    dbms_output.put_line('elapsed seconds: ' || to_char(l_elapsed, '9G999G999D99'));
    dbms_output.put_line('measured throughput: ' || to_char(l_throughput, '999G999D99'));

END;
/

--exec dbms_monitor.session_trace_disable();


