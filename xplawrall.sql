set verify on lines 200 pages 9999
undefine sqlid
accept level char DEFAULT 'ADVANCED' PROMPT "Explain Plan level (BASIC, TYPICAL, ALL, ADVANCED)  (Default : ADVANCED) : "

col cpu_exe format 9999.9999
col ela_exe format 9999.9999
col prds_exe format 9999.9999
col bg_exe format 99999999
col rows_exe format 999999
col snap_time format a14
col inst format 999
col sql_id new_value sqlid noprint
break on plan_hash_value skip 1
select
  sql_id,
  plan_hash_value,
  s.instance_number inst,
  s.snap_id,
  to_char(s.begin_interval_time,'YYYYMMDD:HH24:MI') snap_time,
  executions_delta delta_exe,
  cpu_time_delta/1000000 delta_cpu_sec,
  (case when executions_delta>0 then ((cpu_time_delta/1000000)/executions_delta) else 0 end) cpu_exe,
  (case when executions_delta>0 then ((elapsed_time_delta/1000000)/executions_delta) else 0 end) ela_exe,
  (case when executions_delta>0 then (buffer_gets_delta/executions_delta) else 0 end) bg_exe,
  (case when executions_delta>0 then (disk_reads_delta/executions_delta) else 0 end) prd_exe,
  (case when executions_delta>0 then (rows_processed_delta/executions_delta) else 0 end) rows_exe
from
  dba_hist_sqlstat b,
  dba_hist_snapshot s
where
  b.sql_id = '&sqlid'
  and b.snap_id = s.snap_id
  and s.begin_interval_time >= sysdate-&days_back
  and s.instance_number = b.instance_number
order by
  2,3,4
;
select * from table(dbms_xplan.display_awr('&sqlid','','','&level'))
;
undefine sqlid
clear columns
clear breaks
