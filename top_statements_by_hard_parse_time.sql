column avg_hard_parse_time_ms format 9G999G990D00

select
  sql_id,
  plan_hash_value,
  executions,
  parse_calls,
  avg_hard_parse_time_ms
from
  ( select
      sql_id,
      plan_hash_value,
      executions,
      parse_calls,
      avg_hard_parse_time/1000 avg_hard_parse_time_ms
    from
      v$sqlstats
    order by
      avg_hard_parse_time desc
  )
where
  rownum <= 20
order by
  plan_hash_value
;
