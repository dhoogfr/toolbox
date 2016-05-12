set linesize 201

set echo on
/*
01   sql_type_mismatch              02  optimizer_mismatch          03   outline_mismatch           04   stats_row_mismatch         05   literal_mismatch
06   force_hard_parse               07  explain_plan_cursor         08   buffered_dml_mismatch      09   pdml_env_mismatch          10  inst_drtld_mismatch
11  slave_qc_mismatch               12  typecheck_mismatch          13  auth_check_mismatch         14  bind_mismatch               15  describe_mismatch
16  language_mismatch               17  translation_mismatch        18  bind_equiv_failure          19  insuff_privs                20  insuff_privs_rem
21  remote_trans_mismatch           22  logminer_session_mismatch   23  incomp_ltrl_mismatch        24  overlap_time_mismatch       25  edition_mismatch
26  mv_query_gen_mismatch           27  user_bind_peek_mismatch     28  typchk_dep_mismatch         29  no_trigger_mismatch         30  flashback_cursor
31  anydata_transformation          32  pddl_env_mismatch           33  top_level_rpi_cursor        34  different_long_length       35  logical_standby_apply
36  diff_call_durn                  37  bind_uacs_diff              38  plsql_cmp_switchs_diff      39  cursor_parts_mismatch       40  stb_object_mismatch
41  crossedition_trigger_mismatch   42  pq_slave_mismatch           43  top_level_ddl_mismatch      44  multi_px_mismatch           45  bind_peeked_pq_mismatch
46  mv_rewrite_mismatch             47  roll_invalid_mismatch       48  optimizer_mode_mismatch     49  px_mismatch                 50  mv_staleobj_mismatch
51  flashback_table_mismatch        52  litrep_comp_mismatch        53  plsql_debug                 54  load_optimizer_stats        55  acl_mismatch
56  flashback_archive_mismatch      57  lock_user_schema_failed     58  remote_mapping_mismatch     59  load_runtime_heap_failed    60  hash_match_failed
61  purged_cursor                   62  bind_length_upgradeable     63  use_feedback_stats
*/
set echo off

column 01 format a2
column 02 format a2
column 03 format a2
column 04 format a2
column 05 format a2
column 06 format a2
column 07 format a2
column 08 format a2
column 09 format a2
column 10 format a2
column 11 format a2
column 12 format a2
column 13 format a2
column 14 format a2
column 15 format a2
column 16 format a2
column 17 format a2
column 18 format a2
column 19 format a2
column 20 format a2
column 21 format a2
column 22 format a2
column 23 format a2
column 24 format a2
column 25 format a2
column 26 format a2
column 27 format a2
column 28 format a2
column 29 format a2
column 30 format a2
column 31 format a2
column 32 format a2
column 33 format a2
column 34 format a2
column 35 format a2
column 36 format a2
column 37 format a2
column 38 format a2
column 39 format a2
column 40 format a2
column 41 format a2
column 42 format a2
column 43 format a2
column 44 format a2
column 45 format a2
column 46 format a2
column 47 format a2
column 48 format a2
column 49 format a2
column 50 format a2
column 51 format a2
column 52 format a2
column 53 format a2
column 54 format a2
column 55 format a2
column 56 format a2
column 57 format a2
column 58 format a2
column 59 format a2
column 60 format a2
column 61 format a2
column 62 format a2
column 63 format a2


select
  child_number
  ,sql_type_mismatch              "01"
  ,optimizer_mismatch             "02"
  ,outline_mismatch               "03"
  ,stats_row_mismatch             "04"
  ,literal_mismatch               "05"
  ,force_hard_parse               "06"
  ,explain_plan_cursor            "07"
  ,buffered_dml_mismatch          "08"
  ,pdml_env_mismatch              "09"
  ,inst_drtld_mismatch            "10"
  ,slave_qc_mismatch              "11"
  ,typecheck_mismatch             "12"
  ,auth_check_mismatch            "13"
  ,bind_mismatch                  "14"
  ,describe_mismatch              "15"
  ,language_mismatch              "16"
  ,translation_mismatch           "17"
  ,bind_equiv_failure             "18"
  ,insuff_privs                   "19"
  ,insuff_privs_rem               "20"
  ,remote_trans_mismatch          "21"
  ,logminer_session_mismatch      "22"
  ,incomp_ltrl_mismatch           "23"
  ,overlap_time_mismatch          "24"
  ,edition_mismatch               "25"
  ,mv_query_gen_mismatch          "26"
  ,user_bind_peek_mismatch        "27"
  ,typchk_dep_mismatch            "28"
  ,no_trigger_mismatch            "29"
  ,flashback_cursor               "30"
  ,anydata_transformation         "31"
  ,pddl_env_mismatch              "32"
  ,top_level_rpi_cursor           "33"
  ,different_long_length          "34"
  ,logical_standby_apply          "35"
  ,diff_call_durn                 "36"
  ,bind_uacs_diff                 "37"
  ,plsql_cmp_switchs_diff         "38"
  ,cursor_parts_mismatch          "39"
  ,stb_object_mismatch            "40"
  ,crossedition_trigger_mismatch  "41"
  ,pq_slave_mismatch              "42"
  ,top_level_ddl_mismatch         "43"
  ,multi_px_mismatch              "44"
  ,bind_peeked_pq_mismatch        "45"
  ,mv_rewrite_mismatch            "46"
  ,roll_invalid_mismatch          "47"
  ,optimizer_mode_mismatch        "48"
  ,px_mismatch                    "49"
  ,mv_staleobj_mismatch           "50"
  ,flashback_table_mismatch       "51"
  ,litrep_comp_mismatch           "52"
  ,plsql_debug                    "53"
  ,load_optimizer_stats           "54"
  ,acl_mismatch                   "55"
  ,flashback_archive_mismatch     "56"
  ,lock_user_schema_failed        "57"
  ,remote_mapping_mismatch        "58"
  ,load_runtime_heap_failed       "59"
  ,hash_match_failed              "60"
  ,purged_cursor                  "61"
  ,bind_length_upgradeable        "62"
  ,use_feedback_stats             "63"
from
  v$sql_shared_cursor
where
  sql_id = '&sql_id'
order by
  child_number
;
