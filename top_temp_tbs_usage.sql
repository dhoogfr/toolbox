column temp_used_mb format 999G999G999D99

set verify off

prompt Enter the begindate in the format DD/MM/YYYY HH24:MI
accept bdate prompt 'begin date: '

prompt Enter the enddate in the format DD/MM/YYYY HH24:MI
accept edate prompt 'end date: '


with samples 
as
  ( select
      sample_time,
      nvl(qc_instance_id, instance_number) inst_id,
      nvl(qc_session_id, session_id) sess_id,
      nvl(qc_session_serial#, session_serial#) sess_serial#,
      sql_id,
      temp_space_allocated
    from
      dba_hist_active_sess_history
    where
      temp_space_allocated is not null
      and sample_time between to_date('&bdate', 'DD/MM/YYYY HH24:MI') and to_date('&edate', 'DD/MM/YYYY HH24:MI')
  ),
grouped_samples
as
  ( select
      sample_time,
      inst_id,
      sess_id,
      sess_serial#,
      sql_id,
      sum(temp_space_allocated)/1024/1024 temp_used_mb
    from
      samples
    group by
      sample_time,
      inst_id,
      sess_id,
      sess_serial#, 
      sql_id
  )
select
  to_char(sample_time,'DD/MM/YYYY HH24:MI:SS') datestr,
  inst_id,
  sess_id,
  sess_serial#,
  sql_id,
  temp_used_mb
from
  ( select
      sample_time,
      inst_id,
      sess_id,
      sess_serial#,
      sql_id,
      temp_used_mb
    from
      grouped_samples
    order by
      temp_used_mb desc
  )
where
  rownum <= 30
;

undef bdate
undef edate