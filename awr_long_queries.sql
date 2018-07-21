set linesize 500
set pages 50000
set long 50000
--set markup html on

column total_quries format 9G999G999
column distinct_quries format 9G999G999

column inst_nbr format 999
column begin_interval_time_str format a20
column end_interval_time_str format a20
column module format a20
column action format a15
column sql_profile format a15
column parsing_schema_name format a30
column fetches_delta_str format a14
column sorts_delta_str format a14
column exec_delta_str format a14
column px_exec_delta_str format a14
column disk_reads_delta_str format a14
column buffer_gets_delta_str format a14
column cpu_sec_str format a17
column elaps_sec_str format a17
column sql_text format a500 word_wrapped


--spool awr_queries_longer_than_10_minutes.html

select
  count(*) total_queries,
  count(distinct stat.sql_id) distinct_queries
from
  dba_hist_snapshot         snap
    join dba_hist_sqlstat   stat
      on ( snap.dbid = stat.dbid
           and snap.instance_number = stat.instance_number
           and snap.snap_id = stat.snap_id
         )
    join dba_hist_sqltext   sqlt
      on ( stat.dbid = sqlt.dbid
           and stat.sql_id = sqlt.sql_id
         )
where
  snap.begin_interval_time > trunc(sysdate) - 1 + 19/24
  and stat.parsing_schema_name not in 
    ('SYS','SYSMAN','MDSYS','WKSYS', 'NAGIORA', 'PANDORA'
    )
  and sql_text not like '%/* SQL Analyze(%'
  and sql_text not like 'DECLARE job BINARY_INTEGER%'  
  and stat.elapsed_time_delta > 10 * 60 * 1000000
order by
  stat.elapsed_time_delta
;


select
  snap.instance_number inst_nbr,
  to_char(snap.begin_interval_time, 'DD/MM/YYYY HH24:MI:SS') begin_interval_time_str,
  to_char(snap.end_interval_time, 'DD/MM/YYYY HH24:MI:SS') end_interval_time_str,
  stat.sql_id,
  stat.plan_hash_value,
  to_char(stat.elapsed_time_delta/1000000, '9G999G999G999D99') elaps_sec_str,
  to_char(stat.cpu_time_delta/1000000, '9G999G999G999D99') cpu_sec_str,
  stat.module,
  stat.action,
  stat.sql_profile,
  stat.parsing_schema_name,
  to_char(stat.fetches_delta, '9G999G999G999') fetches_delta_str,
  to_char(stat.sorts_delta, '9G999G999G999') sorts_delta_str,
  to_char(stat.executions_delta, '9G999G999G999') exec_delta_str,
  to_char(stat.px_servers_execs_delta, '9G999G999G999') px_exec_delta_str,
  to_char(stat.disk_reads_delta, '9G999G999G999') disk_reads_delta_str,
  to_char(stat.buffer_gets_delta, '9G999G999G999') buffer_gets_delta_str,
  sqlt.sql_text
from
  dba_hist_snapshot         snap
    join dba_hist_sqlstat   stat
      on ( snap.dbid = stat.dbid
           and snap.instance_number = stat.instance_number
           and snap.snap_id = stat.snap_id
         )
    join dba_hist_sqltext   sqlt
      on ( stat.dbid = sqlt.dbid
           and stat.sql_id = sqlt.sql_id
         )
where
  snap.begin_interval_time > trunc(sysdate) - 1 + 19/24
  and stat.parsing_schema_name not in 
    ('SYS','SYSMAN','MDSYS','WKSYS', 'NAGIORA', 'PANDORA'
    )
  and sql_text not like '%/* SQL Analyze(%'
  and sql_text not like 'DECLARE job BINARY_INTEGER%'
  -- longer then 10 minutes
  and stat.elapsed_time_delta > 10 * 60 * 1000000
order by
  stat.elapsed_time_delta desc
;

--spool off
set markup html off
