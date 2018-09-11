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
