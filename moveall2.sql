set echo off

column order_col1 noprint
column order_col2 noprint

set heading off
set verify off
set feedback off
set echo off

spool tmp.sql

select decode( segment_type, 'TABLE', 
                       segment_name, table_name ) order_col1,
       decode( segment_type, 'TABLE', 1, 2 ) order_col2,
      'alter ' || segment_type || ' ' || segment_name ||
      decode( segment_type, 'TABLE', ' move ', ' rebuild ' ) || 
      chr(10) ||
      ' tablespace ' || decode( segment_type, 'TABLE', tablespace_name, 'ARTIS_NDX') || ';'
  from user_segments, 
       (select table_name, index_name from user_indexes )
 where segment_type in ( 'TABLE', 'INDEX' )
   and segment_name = index_name (+)
 order by 1, 2
/

spool off

set heading on
set verify on
set feedback on
set echo on

REM UNCOMMENT TO AUTO RUN the generated commands
REM ELSE edit tmp.sql, modify as needed and run it
REM @tmp
