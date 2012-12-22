set echo off
set pages 9999
set trimspool on
set linesize 200

column dcol new_value spoolname noprint
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;

select nvl('&1', db_unique_name || '_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '_ora04031_monitoring.txt') dcol from v$database;

set feedback on

spool &spoolname

prompt indications of shared pool space pressure
prompt -----------------------------------------

select *
from ( select to_char(first_value(run_date) over (partition by name order by run_date rows between unbounded preceding and unbounded following), 'DD/MM/YYYY HH24:MI') start_run_date,
              to_char(last_value(run_date) over (partition by name order by run_date rows between unbounded preceding and unbounded following), 'DD/MM/YYYY HH24:MI') end_run_date,
              name,
              ( nvl(last_value(value) over (partition by name order by run_date rows between unbounded preceding and unbounded following),0)
                - nvl(first_value(value) over (partition by name order by run_date rows between unbounded preceding and unbounded following),0)
              ) delta
       from sp_pressure
     )
group by start_run_date, end_run_date, name, delta
order by name;

prompt sizes of selected shared pool heaps
prompt -----------------------------------

column mb format 9G999G999D99

select name, bytes/1024/1024 MB
from v$sgastat
where pool = 'shared pool'
      and name in ('KGLH0', 'free memory', 'SQLA');


prompt KGLH0 / PCUR chunk information
prompt ------------------------------

column kb format 999G999G999D99
column max_kb format 999G999G999D99
column kb format 9G999G999D99
column max_kb format 999G999G999D99

select substr(ksmchcom, 1, instr(ksmchcom, '^') -1) subpool,
       ksmchcls, sum(ksmchsiz)/1024 KB, max(ksmchsiz)/1024 max_kb
from x$ksmsp
where ksmchcom like 'KGLH0%'
      or ksmchcom like 'PCUR%'
group by substr(ksmchcom, 1, instr(ksmchcom, '^') -1), ksmchcls
order by 1, 2;

prompt top sql by sharable mem
prompt -----------------------

column sharable_mem format 9G999G999G999
column users_opening format 9G999 heading  "USERS|OPENING"
column executions format 999G999
column version_count format 99G999  heading "VERSION|COUNT"
column loaded_versions format 99G999  heading "LOADED|VERSIONS"
column open_versions format 99G999  heading "OPEN|VERSIONS"
column kept_versions format 99G999  heading "KEPT|VERSIONS"
column parsing_user_id format 999  heading "P USER"

select *
from ( select sql_id, substr(sql_text,1,40) stm, sharable_mem, users_opening,
              executions, version_count, loaded_versions, open_versions,
              kept_versions, parsing_user_id
       from v$sqlarea
       order by sharable_mem desc
     )
where rownum <= 10;

prompt top sql by version_count
prompt ------------------------

column sharable_mem format 9G999G999G999
column persistent_mem format 9G999G999G999
column sql_fulltext format a100 word_wrapped

select * 
from ( select sql_id, version_count, loaded_versions, sharable_mem, persistent_mem, runtime_mem, optimizer_mode, invalidations, sql_fulltext
       from v$sqlarea 
       order by version_count desc
     )
where rownum <= 10;

prompt mismatch reasons for top sql by number of child cursors
prompt -------------------------------------------------------

set linesize 200
break on sql_id skip 1

select *
from ( select a.*,
              dense_rank() over (order by nbr_child_cursors desc) dr
       from ( select sql_id, child_number, sql_type_mismatch, optimizer_mismatch, outline_mismatch, stats_row_mismatch, literal_mismatch,
                     force_hard_parse, explain_plan_cursor, buffered_dml_mismatch, pdml_env_mismatch, inst_drtld_mismatch, slave_qc_mismatch, 
                     typecheck_mismatch, auth_check_mismatch, bind_mismatch, describe_mismatch, language_mismatch, translation_mismatch, 
                     bind_equiv_failure, insuff_privs, insuff_privs_rem, remote_trans_mismatch, logminer_session_mismatch, incomp_ltrl_mismatch, 
                     overlap_time_mismatch, edition_mismatch, mv_query_gen_mismatch, user_bind_peek_mismatch, typchk_dep_mismatch, no_trigger_mismatch, 
                     flashback_cursor, anydata_transformation, pddl_env_mismatch, top_level_rpi_cursor, different_long_length, logical_standby_apply, 
                     diff_call_durn, bind_uacs_diff, plsql_cmp_switchs_diff, cursor_parts_mismatch, stb_object_mismatch, crossedition_trigger_mismatch, 
                     pq_slave_mismatch, top_level_ddl_mismatch, multi_px_mismatch, bind_peeked_pq_mismatch, mv_rewrite_mismatch, roll_invalid_mismatch, 
                     optimizer_mode_mismatch, px_mismatch, mv_staleobj_mismatch, flashback_table_mismatch, litrep_comp_mismatch, plsql_debug, 
                     load_optimizer_stats, acl_mismatch, flashback_archive_mismatch, lock_user_schema_failed, remote_mapping_mismatch, 
                     load_runtime_heap_failed, hash_match_failed, purged_cursor, bind_length_upgradeable, use_feedback_stats,
                     count(*) over (partition by sql_id) nbr_child_cursors
              from v$sql_shared_cursor
            ) A
     )
where dr <= 5
order by sql_id, child_number;

clear breaks

prompt counts per mismatch reason
prompt ---------------------------

set linesize 2000

select
sum(decode(sql_type_mismatch, 'Y', 1, 0)) sql_type_mismatch
,sum(decode(optimizer_mismatch, 'Y', 1, 0)) optimizer_mismatch
,sum(decode(outline_mismatch, 'Y', 1, 0)) outline_mismatch
,sum(decode(stats_row_mismatch, 'Y', 1, 0)) stats_row_mismatch
,sum(decode(literal_mismatch, 'Y', 1, 0)) literal_mismatch
,sum(decode(force_hard_parse, 'Y', 1, 0)) force_hard_parse
,sum(decode(explain_plan_cursor, 'Y', 1, 0)) explain_plan_cursor
,sum(decode(buffered_dml_mismatch, 'Y', 1, 0)) buffered_dml_mismatch
,sum(decode(pdml_env_mismatch, 'Y', 1, 0)) pdml_env_mismatch
,sum(decode(inst_drtld_mismatch, 'Y', 1, 0)) inst_drtld_mismatch
,sum(decode(slave_qc_mismatch, 'Y', 1, 0)) slave_qc_mismatch
,sum(decode(typecheck_mismatch, 'Y', 1, 0)) typecheck_mismatch
,sum(decode(auth_check_mismatch, 'Y', 1, 0)) auth_check_mismatch
,sum(decode(bind_mismatch, 'Y', 1, 0)) bind_mismatch
,sum(decode(describe_mismatch, 'Y', 1, 0)) describe_mismatch
,sum(decode(language_mismatch, 'Y', 1, 0)) language_mismatch
,sum(decode(translation_mismatch, 'Y', 1, 0)) translation_mismatch
,sum(decode(bind_equiv_failure, 'Y', 1, 0)) bind_equiv_failure
,sum(decode(insuff_privs, 'Y', 1, 0)) insuff_privs
,sum(decode(insuff_privs_rem, 'Y', 1, 0)) insuff_privs_rem
,sum(decode(remote_trans_mismatch, 'Y', 1, 0)) remote_trans_mismatch
,sum(decode(logminer_session_mismatch, 'Y', 1, 0)) logminer_session_mismatch
,sum(decode(incomp_ltrl_mismatch, 'Y', 1, 0)) incomp_ltrl_mismatch
,sum(decode(overlap_time_mismatch, 'Y', 1, 0)) overlap_time_mismatch
,sum(decode(edition_mismatch, 'Y', 1, 0)) edition_mismatch
,sum(decode(mv_query_gen_mismatch, 'Y', 1, 0)) mv_query_gen_mismatch
,sum(decode(user_bind_peek_mismatch, 'Y', 1, 0)) user_bind_peek_mismatch
,sum(decode(typchk_dep_mismatch, 'Y', 1, 0)) typchk_dep_mismatch
,sum(decode(no_trigger_mismatch, 'Y', 1, 0)) no_trigger_mismatch
,sum(decode(flashback_cursor, 'Y', 1, 0)) flashback_cursor
,sum(decode(anydata_transformation, 'Y', 1, 0)) anydata_transformation
,sum(decode(pddl_env_mismatch, 'Y', 1, 0)) pddl_env_mismatch
,sum(decode(top_level_rpi_cursor, 'Y', 1, 0)) top_level_rpi_cursor
,sum(decode(different_long_length, 'Y', 1, 0)) different_long_length
,sum(decode(logical_standby_apply, 'Y', 1, 0)) logical_standby_apply
,sum(decode(diff_call_durn, 'Y', 1, 0)) diff_call_durn
,sum(decode(bind_uacs_diff, 'Y', 1, 0)) bind_uacs_diff
,sum(decode(plsql_cmp_switchs_diff, 'Y', 1, 0)) plsql_cmp_switchs_diff
,sum(decode(cursor_parts_mismatch, 'Y', 1, 0)) cursor_parts_mismatch
,sum(decode(stb_object_mismatch, 'Y', 1, 0)) stb_object_mismatch
,sum(decode(crossedition_trigger_mismatch, 'Y', 1, 0)) crossedition_trigger_mismatch
,sum(decode(pq_slave_mismatch, 'Y', 1, 0)) pq_slave_mismatch
,sum(decode(top_level_ddl_mismatch, 'Y', 1, 0)) top_level_ddl_mismatch
,sum(decode(multi_px_mismatch, 'Y', 1, 0)) multi_px_mismatch
,sum(decode(bind_peeked_pq_mismatch, 'Y', 1, 0)) bind_peeked_pq_mismatch
,sum(decode(mv_rewrite_mismatch, 'Y', 1, 0)) mv_rewrite_mismatch
,sum(decode(roll_invalid_mismatch, 'Y', 1, 0)) roll_invalid_mismatch
,sum(decode(optimizer_mode_mismatch, 'Y', 1, 0)) optimizer_mode_mismatch
,sum(decode(px_mismatch, 'Y', 1, 0)) px_mismatch
,sum(decode(mv_staleobj_mismatch, 'Y', 1, 0)) mv_staleobj_mismatch
,sum(decode(flashback_table_mismatch, 'Y', 1, 0)) flashback_table_mismatch
,sum(decode(litrep_comp_mismatch, 'Y', 1, 0)) litrep_comp_mismatch
,sum(decode(plsql_debug, 'Y', 1, 0)) plsql_debug
,sum(decode(load_optimizer_stats, 'Y', 1, 0)) load_optimizer_stats
,sum(decode(acl_mismatch, 'Y', 1, 0)) acl_mismatch
,sum(decode(flashback_archive_mismatch, 'Y', 1, 0)) flashback_archive_mismatch
,sum(decode(lock_user_schema_failed, 'Y', 1, 0)) lock_user_schema_failed
,sum(decode(remote_mapping_mismatch, 'Y', 1, 0)) remote_mapping_mismatch
,sum(decode(load_runtime_heap_failed, 'Y', 1, 0)) load_runtime_heap_failed
,sum(decode(hash_match_failed, 'Y', 1, 0)) hash_match_failed
,sum(decode(purged_cursor, 'Y', 1, 0)) purged_cursor
,sum(decode(bind_length_upgradeable, 'Y', 1, 0)) bind_length_upgradeable
,sum(decode(use_feedback_stats, 'Y', 1, 0)) use_feedback_stats
from v$sql_shared_cursor;


prompt average cursors per session
prompt ---------------------------

set linesize 120
column avg_per_session format 9G999D99

select avg(counted) avg_per_session
from  ( select count(*) counted
        from v$open_cursor
        group by sid
      );

prompt average cursors per session split by cursor type
prompt ------------------------------------------------

column avg_per_session format 9G999D99

select cursor_type, (count(*)/(select count(distinct sid) from v$open_cursor)) avg_per_session
from v$open_cursor
group by cursor_type;

prompt sharable memory per namespace, type and status
prompt ----------------------------------------------

column namespace format a35
column type format a35
column kb format 999G999G999D99

select namespace, type, status, sum(sharable_mem)/1024 KB
from v$db_object_cache
group by namespace, type, status
order by namespace, type, status;

spool off

exit

