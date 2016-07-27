set linesize 250
set pagesize 50000
set tab off
set long 50000

set scan on

column table_name heading "Table|Name" format a30
column partition_name heading "Partition|Name" format a30
column subpartition_name heading "Subpartition|Name" format a30
column num_rows heading "Number|Of Rows" format 9G999G990
column blocks heading "Blocks" format 999G990
column empty_blocks heading "Empty|Blocks" format 999G990
column avg_space heading "Average|Space" format 9G990
column chain_cnt heading "Chain|Count" format 990
column avg_row_len heading "Average|Row Len" format 990
column column_name  heading "Column|Name" format a30
column nullable heading "Null|Table" format a4
column num_distinct heading "Distinct|Values" format 99G990
column num_nulls heading "Number|Nulls" format 99G990
column num_buckets heading "Number|Buckets" format 990
column density heading "Density" format 990
column index_name heading "Index|Name" format a30
column uniqueness heading "Unique" format a9
column blev heading "B|Tree|Level" format 90
column leaf_blocks heading "Leaf|Blks" format 99990
column distinct_keys heading "Distinct|Keys" format 9G999G990
column avg_leaf_blocks_PER_KEY heading "Average|Leaf Blocks|Per Key" format 99G990
column avg_data_blocks_PER_KEY heading "Average|Data Blocks|Per Key" format 99G990
column clustering_factor heading "Cluster|Factor" format 999G999G990
column column_position heading "Col|Pos" format 990
column col heading "Column|Details" format a24
column column_length heading "Col|Len" format 990
column global_stats heading "Global|Stats" format a6
column user_stats heading "User|Stats" format a6
column sample_size heading "Sample|Size" format 9G999G990
column last_analyzed_str heading "Date|DD/MM/YYYY" format a10
column scope heading "Scope" format a8
column stattype_locked heading "Stats|Lock" format a5
column stale_stats heading "Stale" format a5
column histogram heading "Histogram" format a15

column extension_name heading "Name" format a35
column extension heading "Extension" format a100
column creator heading "Creator" format a7
column droppable heading "Dropable" format a8
column blevel heading "Blevel" format 999999

column index_type heading "Index Type" format a15
column status heading "Status" format a6
column column_expression heading "Expression" format a40
column partition_type heading "Partition|Type" format a9
column subpartition_type heading "Sub Partition|Type" format a13
column locality heading "Locality" format a8
column alignment heading "Alignment" format a12

column notes heading "Notes" format a20

column object_type heading "Object Type" format a15
column object_name heading "Object Name" format a30
column subobject_name heading "Sub Object Name" format a30
column directive_id heading "Directive ID" format 999999999999999999999
column directive_type heading "Type" format a16
column directive_enabled heading "Enabled" format a7
column directive_state heading "State" format a10
column directive_auto_drop heading "Auto|Drop" format a4
column directive_reason heading "Reason" format a30 word_wrapped
column directive_crea_str heading "Created" format a10
column directive_mod_str heading "Modified" format a10
column directive_used_str heading "Used" format a10
column directive_notes heading "Notes" format a200 word_wrapped
column nbr_directives heading "#Directives" format 9G999G999

set verify off
set feedback off
set termout off
column uservar new_value table_owner noprint
select user uservar from dual;
set termout on

undefine table_name
undefine owner

prompt
accept owner prompt 'Please enter Name of Table Owner (Null = &table_owner): '
accept table_name  prompt 'Please enter Table Name to show Statistics for: '


prompt
prompt ********************************************
prompt Table \ Partition \ Subpartition Statistics
prompt ********************************************
prompt

-- table statistics
break on object_type skip 1 duplicates

select 
  table_name,
  partition_name,
  subpartition_name,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  global_stats,
  user_stats,
  sample_size,
  scope,
  stattype_locked,
  to_char(last_analyzed,'DD/MM/YYYY') last_analyzed_str,
  stale_stats
from
  dba_tab_statistics
where 
  owner = nvl('&&Owner',user)
  and table_name = '&&Table_name'
order by
  partition_position nulls first,
  subpartition_position nulls first
;

clear breaks


prompt
prompt ********************************
prompt Extented Statistics Definitions
prompt ********************************
prompt

select
  extension_name,
  extension,
  creator,
  droppable
from
  dba_stat_extensions
where
  owner = nvl('&owner', user)
  and table_name = '&table_name'
order by
  extension_name
;


prompt
prompt *******************************
prompt Table level Column Statistics
prompt *******************************
prompt

-- column statistics
-- unlike the *_(sub)part_tab_col_statistics views, the *_tab_col_statistics view only contains records
-- for the columns with statistics, requiring the dba_tab_columns to be used instead.
-- but dba_tab_columns does not include the "columns" of extented statistics
-- that is why a full outer join is done between dba_tab_columns and dba_tab_col_statistics
select
  nvl(atc.column_name, atcs.column_name) column_name,
  nvl2(atc.column_name, decode( atc.data_type, 
          'NUMBER', atc.data_type || '(' || decode(atc.data_precision,null, data_length || ')', atc.data_precision || ',' || atc.data_scale ||')'),
          'DATE', atc.data_type,
          'LONG', atc.data_type,
          'LONG RAW', atc.data_type,
          'ROWID', atc.data_type,
          'MLSLABEL', atc.data_type,
          atc.data_type || '(' || atc.data_length || ')'
        ) ||' ' || decode(atc.nullable, 'N', 'NOT NULL', 'n', 'NOT NULL', ''), '') col,
  nvl(atc.num_distinct, atcs.num_distinct) num_distinct,
  nvl(atc.density,atcs.density) density,
  nvl(atc.histogram,atcs.histogram) histogram,
  nvl(atc.num_buckets,atcs.num_buckets) num_buckets,
  nvl(atc.num_nulls,atcs.num_nulls) num_nulls,
  nvl(atc.global_stats,atcs.global_stats) global_stats,
  nvl(atc.user_stats,atcs.user_stats) user_stats,
  nvl(atc.sample_size,atcs.sample_size) sample_size,
  to_char(nvl(atc.last_analyzed, atcs.last_analyzed),'DD/MM/YYYY') last_analyzed_str,
  atcs.notes
from
  dba_tab_columns                               atc
    full outer join dba_tab_col_statistics      atcs
     on ( atc.owner = atcs.owner
          and atc.table_name = atcs.table_name
          and atc.column_name = atcs.column_name
        )
where
  ( ( atcs.owner = nvl('&owner',user)
      and atcs.table_name = '&table_name'
    )
    or atcs.owner is null
  )
  and ( ( atc.owner = nvl('&owner',user)
          and atc.table_name = '&table_name'
        )
        or atc.owner is null
      )
order by
  atc.column_id nulls last,
  atcs.column_name
;


prompt
prompt **********************************
prompt Partition Level Column Statistics
prompt **********************************

break on partition_name skip 1

select
  atp.partition_name,
  apcs.column_name,
  apcs.num_distinct,
  apcs.density,
  apcs.histogram,
  apcs.num_buckets,
  apcs.num_nulls,
  apcs.global_stats,
  apcs.user_stats,
  apcs.sample_size,
  to_char(apcs.last_analyzed,'DD/MM/YYYY') last_analyzed_str,
  apcs.notes
from
  dba_tab_partitions                                            atp
    join dba_part_col_statistics                                apcs
      on ( atp.table_owner = apcs.owner
           and atp.table_name = apcs.table_name
           and atp.partition_name = apcs.partition_name
         )
      left outer join dba_tab_columns                           atc
        on ( apcs.owner = atc.owner
             and apcs.table_name = atc.table_name
             and apcs.column_name = atc.column_name
           )
where 
  atp.table_owner = nvl('&Owner',user)
  and atp.table_name = '&Table_name'
order by
  atp.partition_position,
  atc.column_id nulls last,
  apcs.column_name
/

clear breaks


prompt
prompt *************************************
prompt SubPartition Level Column Statistics
prompt *************************************

break on partition_name skip 2 on subpartition_name skip 1

select
  atsp.partition_name,
  atsp.subpartition_name,
  ascs.column_name,
  ascs.num_distinct,
  ascs.density,
  ascs.histogram,
  ascs.num_buckets,
  ascs.num_nulls,
  ascs.global_stats,
  ascs.user_stats,
  ascs.sample_size,
  to_char(ascs.last_analyzed,'DD/MM/YYYY') last_analyzed_str,
  ascs.notes
from
  dba_tab_partitions                                              atp
    join dba_tab_subpartitions                                    atsp
      on ( atp.table_owner = atsp.table_owner
           and atp.table_name = atsp.table_name
           and atp.partition_name = atsp.partition_name
         )
      join dba_subpart_col_statistics                             ascs
        on ( atsp.table_owner = ascs.owner
             and atsp.table_name = ascs.table_name
             and atsp.subpartition_name = ascs.subpartition_name
          )
        left outer join dba_tab_columns                           atc
          on ( ascs.owner = atc.owner
               and ascs.table_name = atc.table_name
               and ascs.column_name = atc.column_name
            )
where 
  atp.table_owner = nvl('&Owner',user)
  and atp.table_name = '&Table_name'
order by
  atp.partition_position,
  atsp.subpartition_position,
  atc.column_id nulls last,
  ascs.column_name
/

clear breaks


prompt
prompt *********************************************
prompt Index (Partition \ Subpartition)  Statistics
prompt *********************************************

prompt
Prompt Index Definitions
prompt -----------------

break on index_name skip page

select 
  ind.index_name, 
  ind.index_type, 
  decode(ind.uniqueness,'UNIQUE', 'Y', 'N') uniqueness, 
  ind.status, 
  inc.column_position, 
  inc.column_name, 
  ine.column_expression,
  inp.partitioning_type,
  inp.subpartitioning_type,
  inp.locality,
  inp.alignment
from 
  dba_indexes                                       ind
    join dba_ind_columns                            inc
      on ( inc.index_owner = ind.owner
           and inc.index_name = ind.index_name
         )
    left outer join dba_ind_expressions             ine
      on ( ine.index_owner = inc.index_owner
           and ine.index_name = inc.index_name
           and ine.column_position = inc.column_position
         )
    left outer join dba_part_indexes                inp
      on ( inp.owner = ind.owner
           and inp.index_name = ind.index_name
         )
where 
  ind.table_owner = nvl('&Owner',user)
  and ind.table_name = '&Table_name'
order by
  ind.index_name, 
  inc.column_position
;

clear breaks

prompt
Prompt Index Statistics
prompt ----------------

break on index_name skip page on partition_name skip 1

select
  index_name, 
  partition_name, 
  subpartition_name,
  blevel, 
  leaf_blocks, 
  distinct_keys, 
  avg_leaf_blocks_per_key, 
  avg_data_blocks_per_key, 
  clustering_factor, 
  num_rows, 
  sample_size, 
  to_char(last_analyzed, 'DD/MM/YYYY') last_analyzed_str,
  user_stats, 
  global_stats, 
  stattype_locked, 
  stale_stats, 
  scope 
from
  dba_ind_statistics 
where
  table_owner = nvl('&owner',user)
  and table_name = '&table_name'  
order by
  index_name, 
  partition_position nulls first, 
  subpartition_position nulls first
;

clear breaks


prompt
prompt **************
prompt CBO Directives
prompt **************

prompt
Prompt Overview
prompt --------

select
  pd.type                                     directive_type,
  pd.enabled                                  directive_enabled,
  pd.state                                    directive_state,
  count(*)                                    nbr_directives
from
  dba_sql_plan_dir_objects          pdo
    join dba_sql_plan_directives    pd
      on ( pdo.directive_id = pd.directive_id
         )
where
  pdo.owner = nvl('&owner',user)
  and pdo.object_name = '&table_name'  
group by
  pd.type,
  pd.enabled,
  pd.state
order by
  pd.type,
  pd.enabled,
  pd.state
;

prompt
Prompt Directive Details
prompt ------------------

break on directive_id skip page

select
  pd.directive_id,
  pdo.object_type,
  pdo.object_name,
  pdo.subobject_name,
  pd.type                                     directive_type,
  pd.enabled                                  directive_enabled,
  pd.state                                    directive_state,
  pd.auto_drop                                directive_auto_drop,
  pd.reason                                   directive_reason,
  to_char(pd.created, 'DD/MM/YYYY')           directive_crea_str,
  to_char(pd.last_modified, 'DD/MM/YYYY')     directive_mod_str,
  to_char(pd.last_used, 'DD/MM/YYYY')         directive_used_str,
  pd.notes                                    directive_notes
from
  dba_sql_plan_dir_objects          pdo
    join dba_sql_plan_directives    pd
      on ( pdo.directive_id = pd.directive_id
         )
where
  pdo.owner = nvl('&owner',user)
  and pdo.object_name = '&table_name'  
order by 
  pd.directive_id,
  pdo.object_type, 
  pdo.object_name, 
  pdo.subobject_name
;

clear breaks


-- the end
undefine table_name
undefine owner
