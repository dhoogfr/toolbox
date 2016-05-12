set linesize 120
set pagesize 9999
set echo off
set verify off

prompt Enter the begindate in the format DD/MM/YYYY HH24:MI
accept bdate prompt 'begin date: '

prompt Enter the enddate in the format DD/MM/YYYY HH24:MI
accept edate prompt 'end date: '

column undo_retention_time format a20

select value undo_retention_time
from v$parameter
where name = 'undo_retention';


column undo_space format 999G999G999D99
column max_undo_space format 999G999G999D99
column undo_tbs format a15

select sum(bytes)/1024/1024 undo_space, sum(maxbytes)/1024/1024 max_undo_space
from dba_data_files
where tablespace_name = 
        ( select value 
          from v$parameter 
          where name = 'undo_tablespace'
        );

column begin_time format a17
column end_time format a17
column retention_undo_usage format 9G999G999D99 heading "Undo ret period"
column curr_undo_usage format 9G999D99 heading "undo usage"
column pct_used format 999D99
column ts_ss format 99D99

select to_char(begin_time,'DD/MM/YYYY HH24:MI') begin_time, 
       to_char(end_time,'DD/MM/YYYY HH24:MI') end_time,
       (select name from v$tablespace where ts# = undotsn) undo_tbs, 
       curr_undo_usage, retention_undo_usage,
       (100 * retention_undo_usage /  
        ( select sum(greatest(bytes,maxbytes))/1024/1024
          from dba_data_files
          where tablespace_name = (select name from v$tablespace where ts# = undotsn)
        )
       ) pct_used,
       ts_hh,
       ts_mi,
       ts_ss
from ( 
select undotsn,
       begin_time, end_time, 
       undoblks * 
        ( select block_size 
          from dba_tablespaces 
          where tablespace_name = (select name from v$tablespace where ts# = undotsn)
        ) /1024/1024 curr_undo_usage,
       sum(undoblks)
        over
            ( order by end_time 
              range ( select value/24/60/60 
                      from v$parameter 
                      where name = 'undo_retention'
                    ) preceding
            )
       * ( select block_size 
           from dba_tablespaces 
           where tablespace_name = (select name from v$tablespace where ts# = undotsn)
         ) /1024/1024 retention_undo_usage,
         decode(maxquerylen, 0, 0, extract(hour from (systimestamp + maxquerylen/24/60/60 - systimestamp))) ts_hh,
         decode(maxquerylen, 0, 0, extract(minute from (systimestamp + maxquerylen/24/60/60 - systimestamp))) ts_mi,
         decode(maxquerylen, 0, 0, extract(second from (systimestamp + maxquerylen/24/60/60 - systimestamp))) ts_ss
from v$undostat 
) U
where begin_time >= to_date('&bdate', 'DD/MM/YYYY HH24:MI')
      and end_time <= to_date('&edate', 'DD/MM/YYYY HH24:MI')
order by U.begin_time;