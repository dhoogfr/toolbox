set linesize 120
set pages 50000

column sql_id           format a15              heading "sql id"
column plan_hash_value  format 99999999999      heading "plan hash"
column total_exec       format 999G999G999G999  heading "total exec|(µs)"
column total_elap       format 999G999G999G999  heading "total elap|(µs)"
column avg_elap         format 999G999G999D99   heading "avg elap|(µs)"

select
  sql_id,
  plan_hash_value,
  sum(executions_delta)                               total_exec,
  sum(elapsed_time_delta)                             total_elap,
  (sum(elapsed_time_delta) / sum(executions_delta))   avg_elap 
from
  dba_hist_sqlstat
where
  sql_id = '&sql_id'
group by
  sql_id,
  plan_hash_value
order by
  avg_elap desc
;

