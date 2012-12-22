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
