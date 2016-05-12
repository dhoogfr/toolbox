/* This script generates an overview of the memory settings and usage of a database
   Run the script as an admin user (eg SYS) from within sqlplus.
   A logfile will be created in the current working directory
*/

--- set layout options
clear breaks
set pagesize 9999
set linesize 150
set verify off
set echo off
set feedback off
set trimspool on


--  initialize spoolfile
column dcol new_value spoolname noprint
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;

select
  nvl('&1', db_unique_name || '_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '_memory_report.log') dcol 
from 
  v$database
;

undefine 1

spool &spoolname


--- db and platform identification
prompt
prompt DB IDENTIFICATION
prompt ------------------

set linesize 200
column platform_name format a40
column name format a15
column db_unique_name format a20

select
  dbid, name, db_unique_name, database_role, platform_name 
from
  v$database
;

column host_name format a40
prompt

select
  instance_number, instance_name, host_name, version
from 
  gv$instance
order by
  instance_number
;

--- sga spfile parameter
prompt
prompt
prompt SGA PARAMETERS
prompt --------------

column name format a40
column value format a25
column description format a40 word_wrapped
set linesize 150

select ksppinm name, ksppstvl value, ksppstdf isdefault, x.inst_id inst_id, ksppdesc description
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ksppinm in 
        ( 'sga_target', 'sga_max_target', 'memory_target', 'db_cache_size', 
          'db_2k_cache_size', 'db_4k_cache_size', 'db_8k_cache_size', 
          'db_16k_cache_size', 'db_32k_cache_size', 'db_keep_cache_size', 
          'db_recycle_cache_size', 'java_pool_size', 'large_pool_size', 
          'olap_page_pool_size'
        )
order by ksppinm, x.inst_id;


--- sga overview
prompt
prompt
prompt SGA OVERVIEW
prompt ------------

set linesize 120
set pagesize 9999

column component format a40
column curr_mb format 99G999D99
column min_mb format 99G999D99
column max_mb format 99G999D99
column user_mb format 99G999D99
column granule_mb format 99G999D99

compute sum of curr_mb on report

break on report

select component, current_size/1024/1024 curr_mb, min_size/1024/1024 min_mb, max_size/1024/1024 max_mb, 
       user_specified_size/1024/1024 user_mb, granule_size/1024/1024 granule_mb
from v$sga_dynamic_components
order by component;

clear breaks

--- sga resizes
prompt
prompt
prompt SGA RESIZE OPERATIONS
prompt ---------------------

set linesize 140
set pages 9999

column initial_mb format 999G999D99
column target_mb format 999G999D99
column final_mb format 999G999D99
column component format a30

select *
from  ( select to_char(start_time, 'DD/MM/YYYY HH24:MI:SS') start_time, to_char(end_time, 'DD/MM/YYYY HH24:MI:SS') end_time, 
               component, oper_type, oper_mode, initial_size/1024/1024 initial_mb, target_size/1024/1024 target_mb, 
               final_size/1024/1024 final_mb, status
        from v$sga_resize_ops a
        order by a.start_time desc
      )
where rownum <= 40;


--- sqlcursor memory usage per parsing schema
prompt
prompt
prompt SQL CURSOR MEMORY
prompt -----------------

set linesize 150

column sharable_mem_kb format 99G999G999D00
column persistent_mem_kb format 99G999G999D00
column runtime_mem_kb format 99G999G999D00
column cursor_cnt format 999G999G990
column unique_cursor_cnt format 999G999G990

compute sum of sharable_mem_kb on report
compute sum of persistent_mem_kb on report
compute sum of runtime_mem_kb on report
compute sum of cursor_cnt on report
compute sum of unique_cursor_cnt on report

break on report

with
 childs as
   ( select
       parsing_schema_id,
       sql_id,
       count(*) child_cnt
     from
       v$sql
     group by
       parsing_schema_id,
       sql_id
   ),
 mchild as
   ( select
       parsing_schema_id,
       max(child_cnt) max_child_cnt
     from
       childs
     group by
       parsing_schema_id
   ),
 vsql as
   ( select
       parsing_schema_id,
       count(*) cursor_cnt,
       count(distinct sql_id) unique_cursor_cnt,
       sum(sharable_mem)/1024 sharable_mem_kb,
       sum(persistent_mem)/1024 persistent_mem_kb,
       sum(runtime_mem)/1024 runtime_mem_kb
     from
       v$sql
     group by
       parsing_schema_id
   )
select
  username, cursor_cnt, unique_cursor_cnt, max_child_cnt, 
  sharable_mem_kb, persistent_mem_kb, runtime_mem_kb
from
  mchild,
  vsql,
  dba_users     usr
where
  vsql.parsing_schema_id = mchild.parsing_schema_id
  and vsql.parsing_schema_id = usr.user_id
order by
  username
;

clear breaks
clear computes

--- Top sql cursors by shared memory
prompt
prompt
prompt TOP SQL CURSORS (by shared memory)
prompt ----------------------------------

set linesize 150

column sharable_mem_kb format 99G999G999D00
column persistent_mem_kb format 99G999G999D00
column runtime_mem_kb format 99G999G999D00

select
  *
from
  ( select
      sql_id,
      sum(sharable_mem)/1024 sharable_mem_kb,
      sum(persistent_mem)/1024 persistent_mem_kb,
      sum(runtime_mem)/1024 runtime_mem_kb,
      count(*) child_cnt,
      parsing_schema_name
    from
      v$sql
    group by
      sql_id,
      parsing_schema_name
    order by
      sharable_mem_kb desc,
      parsing_schema_name
  )
where
  rownum <= 10
;

--- memory usage by pool
prompt
prompt
prompt POOL OVERVIEW
prompt -------------

column bytes format 999G999G999G999

compute sum of bytes on pool
break on pool skip 1
select pool, name, bytes
from v$sgastat
order by pool, name;

--- END OF SCRIPT
spool off
