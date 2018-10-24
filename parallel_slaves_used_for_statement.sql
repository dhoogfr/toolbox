--WIP

select 
  to_char(hsnp.begin_interval_time, 'DD/MM/YYYY HH24:MI') begin_interval_time_str,
  to_char(hsnp.end_interval_time, 'DD/MM/YYYY HH24:MI') end_interval_time_str,
  hsnp.instance_number,
  hsnp.snap_id,
  hsql.version_count,
  hsql.plan_hash_value,
  hsql.executions_total,
  hsql.executions_delta,
  hsql.parse_calls_total,
  hsql.parse_calls_delta,
  hsql.px_servers_execs_total,
  hsql.px_servers_execs_delta
from
  dba_hist_sqlstat            hsql
    join dba_hist_snapshot    hsnp
      on ( hsql.snap_id = hsnp.snap_id 
           and hsql.instance_number = hsnp.instance_number
         )
where
  sql_id = '3vk9k0uczhm9q'
  and hsnp.begin_interval_time >= sysdate - 1
order by
  hsnp.begin_interval_time,
  hsnp.instance_number,
  hsql.plan_hash_value
;


select 
  to_char(begin_interval_time, 'DD/MM/YYYY HH24:MI') begin_interval_time_str,
  to_char(end_interval_time, 'DD/MM/YYYY HH24:MI') end_interval_time_str,
  instance_number,
  snap_id,
--  sum_px_server_exec_total,
  sum_px_server_exec_delta,
  total_elapsed_time,
  parallel_statements_cnt
from
  ( select
      hsnp.begin_interval_time,
      hsnp.end_interval_time,
      hsnp.instance_number,
      hsnp.snap_id,
--      sum(hsql.px_servers_execs_total) sum_px_server_exec_total,
      sum(hsql.px_servers_execs_delta) sum_px_server_exec_delta,
      sum(hsql.elapsed_time_delta) total_elapsed_time,
      count(*) parallel_statements_cnt
    from
      dba_hist_sqlstat            hsql
        join dba_hist_snapshot    hsnp
          on ( hsql.snap_id = hsnp.snap_id 
               and hsql.instance_number = hsnp.instance_number
             )
    where
      hsql.px_servers_execs_delta > 0
      and hsnp.begin_interval_time >= sysdate - 1
    group by
      hsnp.begin_interval_time,
      hsnp.end_interval_time,
      hsnp.instance_number,
      hsnp.snap_id
  )
order by
  trunc(begin_interval_time, 'MI'),
  instance_number
;
 