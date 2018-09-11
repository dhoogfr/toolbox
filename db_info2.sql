/* run this script as a dba user
   
   on the db server, from the directory where this script is stored:
   
       set ORACLE_SID=<DB NAME>
       sqlplus "/ as sysdba"
       @db_info.sql <logfile>
       exit
   
    this will generate a logfile (db_info.txt) in the current directory
    
*/


set pagesize 9999
set linesize 150
set serveroutput on
set trimspool on
set echo off
set feedback off

spool &1.txt

--------------------------------------------- DB ----------------------------------------------------------------------

column platform_name format a40
column name format a15
column db_unique_name format a20

select name, db_unique_name, platform_name, flashback_on, log_mode 
from v$database;

--------------------------------------------- DB PARAMETERS ------------------------------------------------------------
set linesize 180
set pagesize 9999
COLUMN display_value FORMAT a15 word_wrapped
COLUMN value FORMAT a75 word_wrapped
COLUMN name FORMAT a35

select x.inst_id inst_id,ksppinm name,ksppity type,
       ksppstvl value, ksppstdf isdefault
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ( ksppstdf = 'FALSE'
            or translate(ksppinm,'_','#') like '##%' 
          --  or translate(ksppinm,'_','#') like '#%'
          )
order by x.inst_id, ksppinm;

--------------------------------------------- INSTALLED OPTIONS --------------------------------------------------------

column comp_name format a50

select comp_name, version, status 
from dba_registry 
order by comp_name;

--------------------------------------------- DB SIZES ------------------------------------------------------------------

column name format a25 heading "tablespace name" 
column space_mb format 99g999g990D99 heading "curr df mbytes" 
column maxspace_mb format 99g999g990D99 heading "max df mbytes" 
column used format 99g999g990D99 heading "used mbytes" 
column df_free format 99g999g990D99 heading "curr df free mbytes"
column maxdf_free format 99g999g990D99 heading "max df free mbytes"
column pct_free format 990D99 heading "% free"
column pct_maxfile_free format 990D99 heading "% maxfile free"

break on report

compute sum of space_mb on report
compute sum of maxspace_mb on report
compute sum of df_free on report
compute sum of maxdf_free on report
compute sum of used on report

prompt
prompt DB - Sizes
prompt __________

select df.tablespace_name name, df.space space_mb, df.maxspace maxspace_mb, (df.space - nvl(fs.freespace,0)) used,
       nvl(fs.freespace,0) df_free, (nvl(fs.freespace,0) + df.maxspace - df.space) maxdf_free, 
       100 * (nvl(fs.freespace,0) / df.space) pct_free, 
       100 * ((nvl(fs.freespace,0) + df.maxspace - df.space) / df.maxspace) pct_maxfile_free
from ( select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_data_files
       group by tablespace_name
     ) df,
     ( select tablespace_name, sum(bytes)/1024/1024 freespace
       from dba_free_space
       group by tablespace_name
     ) fs
where df.tablespace_name = fs.tablespace_name(+)
order by name;

clear breaks


--------------------------------------------- TABLESPACE INFO --------------------------------------------------------------

prompt
prompt tablespace info
prompt _______________

column max_mb format 9G999G990D99
column curr_mb format 9G999G990D99
column free_mb format 9G999G990D99
column pct_free format 900D99 heading "%FREE"
column NE format 999999D99
column SSM format a6
column AT format a8
column tablespace_name format a20
column EM format a10
column contents format a15
column block_size format 99999 heading bsize

select A.tablespace_name, block_size, A.contents, extent_management EM, allocation_type AT,
       segment_space_management ssm, decode(allocation_type, 'UNIFORM',next_extent/1024,'') NE,
       B.max_mb, B.curr_mb,
       (B.max_mb - B.curr_mb) + nvl(c.free_mb,0) free_mb, 
       ((100/B.max_mb)*(B.max_mb - B.curr_mb + nvl(c.free_mb,0))) pct_free
from dba_tablespaces A,
     ( select tablespace_name, sum(bytes)/1024/1024 curr_mb, 
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 curr_mb,
              sum(greatest(bytes, maxbytes))/1024/1024 max_mb
       from dba_temp_files
       group by tablespace_name
     ) B,
     ( select tablespace_name, sum(bytes)/1024/1024 free_mb
       from dba_free_space
       group by tablespace_name
     ) C
where A.tablespace_name = B.tablespace_name
      and A.tablespace_name = C.tablespace_name(+)
order by tablespace_name;

--------------------------------------------- DF DETAILS ------------------------------------------------------------------

column curr_mb format 9G999G990D99
column max_mb format 9G9999990D99
column incr_mb format 9G999G990D99
column file_name format a70
--column file_name format a60
column tablespace_name format a20
break on tablespace_name skip 1
set linesize 150
set pagesize 999

prompt
prompt datafiles info
prompt ______________

select A.tablespace_name, file_id, file_name, bytes/1024/1024 curr_mb, autoextensible, 
       maxbytes/1024/1024 max_mb, (increment_by * block_size)/1024/1024 incr_mb
from ( select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_data_files
       union all
       select tablespace_name, file_id, file_name, bytes, autoextensible, maxbytes,
              increment_by
       from dba_temp_files
     ) A, dba_tablespaces B
where A.tablespace_name = B.tablespace_name
order by A.tablespace_name, file_name;

clear breaks;

--------------------------------------------- ONLINE REDO INFO ----------------------------------------------------------------

column member format a55
column type format a10
column status format a20
column arch format a4

break on type on thread# nodup skip 1 on type nodup on GROUP# nodup

prompt
prompt online redo info
prompt ________________

select type, A.thread#, A.group#, B.member, A.bytes/1024/1024 mb,A.status, arch
from ( select group#, thread#, bytes, status, archived arch
       from v$log
       union all
       select group#, thread#, bytes, status, archived arch
       from v$standby_log
     ) A, v$logfile B
where A.group# = B.group#
order by type, A.thread#, A.group#, B.member;

clear breaks


--------------------------------------------- REDO SIZES ------------------------------------------------------------------


column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

prompt
prompt redo sizes
prompt __________

column start_day format a22
column end_day format a22
column days_between format 99
column avg_archived_per_day format a13 heading avg_gen

select to_char(min(dag), 'DD/MM/YYYY HH24:MI:SS') start_day, to_char(max(dag) + 1 - 1/(24*60*60), 'DD/MM/YYYY HH24:MI:SS') end_day,
       (max(dag) - min(dag) + 1) days_between,
       to_char(avg(gen_archived_size),'9G999G999D99') avg_archived_per_day
from ( select trunc(completion_time) dag, sum(blocks * block_size)/1024/1024 gen_archived_size
       from v$archived_log
       where standby_dest = 'NO'
             and months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );

/* 
archived redo over the (max) last 10 days
*/
column day_arch_size format 99G999D99
column day_arch# format 999G999
column graph format a15
column dayname format a12
column day format a12

select to_char(day, 'DD/MM/YYYY') day, to_char(day,'DAY') dayname, day_arch_size, day_arch#, graph
from ( select trunc(completion_time) day, sum(blocks * block_size)/1024/1024 day_arch_size, count(*) day_arch#,
              rpad('*',floor(count(*)/10),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 10
       group by trunc(completion_time)
       order by day
     );
     
/*
archived redo per hour over the (max) last 2 days
*/
column hour_arch_size format 99G999D99
column hour_arch# format 9G999
column graph format a15
column dayname format a12
column dayhour format a18
break on dayname skip 1

select to_char(dayhour,'DAY') dayname, to_char(dayhour, 'DD/MM/YYYY HH24:MI') dayhour, hour_arch_size, hour_arch#, graph
from ( select trunc(completion_time, 'HH') dayhour, sum(blocks * block_size)/1024/1024 hour_arch_size, count(*) hour_arch#,
              rpad('*',floor(count(*)/4),'*') graph
       from v$archived_log
       where standby_dest = 'NO'
             and completion_time >= trunc(sysdate) - 2
       group by trunc(completion_time, 'HH')
       order by dayhour
     );
     
clear breaks;
     
spool off
