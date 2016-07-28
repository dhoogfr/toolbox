-- setup the reporting environment
set linesize 250
set pagesize 50000
set tab off
set long 50000
set scan on

column alignment heading "Alignment" format a12
column avg_data_blocks_PER_KEY heading "Average|Data Blocks|Per Key" format 99G990
column avg_leaf_blocks_PER_KEY heading "Average|Leaf Blocks|Per Key" format 99G990
column avg_row_len heading "Average|Row Len" format 990
column avg_space heading "Average|Space" format 9G990
column blev heading "B|Tree|Level" format 90
column blevel heading "Blevel" format 999999
column blocks heading "Blocks" format 999G990
column chain_cnt heading "Chain|Count" format 990
column clustering_factor heading "Cluster|Factor" format 999G999G990
column col heading "Column|Details" format a24
column column_expression heading "Expression" format a40
column column_length heading "Col|Len" format 990
column column_name  heading "Column|Name" format a30
column column_position heading "Col|Pos" format 990
column creator heading "Creator" format a7
column density heading "Density" format 990
column directive_auto_drop heading "Auto|Drop" format a4
column directive_crea_str heading "Created" format a10
column directive_enabled heading "Enabled" format a7
column directive_id heading "Directive ID" format 999999999999999999999
column directive_mod_str heading "Modified" format a10
column directive_notes heading "Notes" format a200 word_wrapped
column directive_reason heading "Reason" format a30 word_wrapped
column directive_state heading "State" format a10
column directive_type heading "Type" format a16
column directive_used_str heading "Used" format a10
column distinct_keys heading "Distinct|Keys" format 9G999G990
column droppable heading "Dropable" format a8
column empty_blocks heading "Empty|Blocks" format 999G990
column extension heading "Extension" format a100
column extension_name heading "Name" format a35
column global_stats heading "Global|Stats" format a6
column histogram heading "Histogram" format a15
column index_name heading "Index|Name" format a30
column index_type heading "Index Type" format a15
column last_analyzed_str heading "Date|DD/MM/YYYY" format a10
column leaf_blocks heading "Leaf|Blks" format 99990
column locality heading "Locality" format a8
column nbr_directives heading "#Directives" format 9G999G999
column notes heading "Notes" format a20
column nullable heading "Null|Table" format a4
column num_buckets heading "Number|Buckets" format 990
column num_distinct heading "Distinct|Values" format 99G990
column num_nulls heading "Number|Nulls" format 99G990
column num_rows heading "Number|Of Rows" format 9G999G990
column object_name heading "Object Name" format a30
column object_type heading "Object Type" format a15
column partition_name heading "Partition|Name" format a30
column partition_type heading "Partition|Type" format a9
column sample_size heading "Sample|Size" format 9G999G990
column scope heading "Scope" format a8
column stale_stats heading "Stale" format a5
column stattype_locked heading "Stats|Lock" format a5
column status heading "Status" format a6
column subobject_name heading "Sub Object Name" format a30
column subpartition_name heading "Subpartition|Name" format a30
column subpartition_type heading "Sub Partition|Type" format a13
column table_name heading "Table|Name" format a30
column uniqueness heading "Unique" format a9
column user_stats heading "User|Stats" format a6

-- cleanup any dangling variables
undefine _owner
undefine _table_name
undefine _table_stats
undefine _tab_part_name
undefine _tab_subpart_name
undefine _column_stats
undefine _index_stats
undefine _index_name
undefine _ind_part_name
undefine _ind_subpart_name
undefine _cbo_directives
undefine _default_owner

-- grab the curent user
set verify off
set feedback off
set termout off
column uservar new_value _default_owner noprint
select user uservar from dual;
set termout on

-- get the user options on which part of the report should be shown and the filters to be applied
prompt
accept _owner default &_default_owner prompt 'Table owner (default &_default_owner): '
accept _table_name prompt 'Table name: '
accept _table_stats default 'YES' prompt 'Display table stats (YES|NO, default YES): '
accept _tab_part_name default '' prompt 'Table partition name (default = no filter, / = none): '
accept _tab_subpart_name default '' prompt 'Table sub partition name (default = no filter, / = none): '
accept _column_stats default 'YES' prompt 'Display column statistics (YES|NO, default YES): '
accept _index_stats default 'NO' prompt 'Display index statistics (YES|NO, default NO): '
accept _index_name default '' prompt 'Index name (default = no filter): '
accept _ind_part_name default '' prompt 'Index partition name (default = no filter, / = none): '
accept _ind_subpart_name default '' prompt 'Index sub partition name (default = no filter, / = none): '
accept _cbo_directives default 'NO' prompt 'Display CBO directives details (YES|NO, default NO): '
prompt

-- use a refcursor and autoprint to allow parts of the report to be toggled on and off
var c_result refcursor
set autoprint on
set serveroutput on

-- actual reporting starts here


-- table statistics
break on object_type skip 1 duplicates
BEGIN

  if upper('&_table_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('********************************************');
    dbms_output.put_line('Table \ Partition \ Subpartition Statistics');
    dbms_output.put_line('********************************************');

    open :c_result for
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
        --filter the table stats on the given owner and table name
        owner = '&_owner'
        and table_name = '&_table_name'
        --apply optional filter on the partitions listed
        and ( partition_name = nvl('&_tab_part_name', partition_name)
              or partition_name is null
              or subpartition_name = nvl('&_tab_subpart_name', subpartition_name)
            )
        --apply optional filter on the sub partitions listed
        and ( subpartition_name = nvl('&_tab_subpart_name', subpartition_name)
              or subpartition_name is null
            )
      order by
        partition_position nulls first,
        subpartition_position nulls first
      ;

    else

      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks

-- extented statistics definitions
BEGIN

  if upper('&_column_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('********************************');
    dbms_output.put_line('Extented Statistics Definitions');
    dbms_output.put_line('********************************');

    open :c_result for
      select
        extension_name,
        extension,
        creator,
        droppable
      from
        dba_stat_extensions
      where
        --filter the extented stats def on the given owner and table name
        owner = '&_owner'
        and table_name = '&_table_name'
      order by
        extension_name
      ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/


-- column statistics
BEGIN

  if upper('&_column_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('******************************');
    dbms_output.put_line('Table level Column Statistics');
    dbms_output.put_line('******************************');

    -- unlike the *_(sub)part_tab_col_statistics views, the *_tab_col_statistics view only contains records
    -- for the columns with statistics, requiring the dba_tab_columns to be used instead.
    -- but dba_tab_columns does not include the "columns" of extented statistics
    -- that is why a full outer join is done between dba_tab_columns and dba_tab_col_statistics
    open :c_result for
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
        --filter the column statistics on the given owner and table name (for both tables due to the full outer join)
        ( ( atcs.owner = '&_owner'
            and atcs.table_name = '&_table_name'
          )
          or atcs.owner is null
        )
        and ( ( atc.owner = '&_owner'
                and atc.table_name = '&_table_name'
              )
              or atc.owner is null
            )
      order by
        atc.column_id nulls last,
        atcs.column_name
      ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/


-- partition level column statistics
break on partition_name skip 1

BEGIN

  if upper('&_column_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('**********************************');
    dbms_output.put_line('Partition Level Column Statistics');
    dbms_output.put_line('**********************************');

      open :c_result for
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
          --filter the column statistics on the given owner and table name
          atp.table_owner = '&_owner'
          and atp.table_name = '&_table_name'
          --apply optional filter on the partitions listed
          and atp.partition_name = nvl('&_tab_part_name', atp.partition_name)
        order by
          atp.partition_position,
          atc.column_id nulls last,
          apcs.column_name
        ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks


-- sub partition level column statistics
break on partition_name skip 2 on subpartition_name skip 1

BEGIN

  if upper('&_column_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('**************************************');
    dbms_output.put_line('Sub Partition Level Column Statistics');
    dbms_output.put_line('**************************************');

      open :c_result for
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
          --filter the column statistics on the given owner and table name
          atp.table_owner = '&_owner'
          and atp.table_name = '&_table_name'
          --apply optional filter on the partitions listed
          and ( atsp.partition_name = nvl('&_tab_part_name', atsp.partition_name)
                or atsp.subpartition_name = nvl('&_tab_subpart_name', atsp.subpartition_name)
              )
          --apply optional filter on the sub partitions listed
          and atsp.subpartition_name = nvl('&_tab_subpart_name', atsp.subpartition_name)
        order by
          atp.partition_position,
          atsp.subpartition_position,
          atc.column_id nulls last,
          ascs.column_name
        ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks


-- index definitions
break on index_name skip page

BEGIN

  if upper('&_index_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.put_line('*********************************************');
    dbms_output.put_line('Index (Partition \ Subpartition)  Statistics');
    dbms_output.put_line('*********************************************');
    dbms_output.new_line;

    dbms_output.put_line('Index Definitions');
    dbms_output.put_line('------------------');

      open :c_result for
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
          --filter the indexes on the given owner and table name
          ind.table_owner = '&_owner'
          and ind.table_name = '&_table_name'
          --apply optional filter on the indexes listed
          and ind.index_name = nvl('&_index_name', ind.index_name)
        order by
          ind.index_name, 
          inc.column_position
        ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks


-- index statistics
break on index_name skip page on partition_name skip 1

BEGIN

  if upper('&_index_stats') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('Index Statistics');
    dbms_output.put_line('-----------------');

      open :c_result for
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
          --filter the indexes on the given owner and table name
          table_owner = '&_owner'
          and table_name = '&_table_name'
          --apply optional filter on the indexes listed
          and index_name = nvl('&_index_name', index_name)
          --apply optional filter on the partitions listed
          and ( partition_name = nvl('&_ind_part_name', partition_name)
                or partition_name is null
                or subpartition_name = '&_ind_subpart_name'
              )
          --apply optional filter on the sub partitions listed
          and ( subpartition_name = nvl('&_ind_subpart_name', subpartition_name)
                or subpartition_name is null
              )
        order by
          index_name, 
          partition_position nulls first, 
          subpartition_position nulls first
        ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks


-- CBO Directives
BEGIN

  dbms_output.new_line;
  dbms_output.put_line('***************');
  dbms_output.put_line('CBO Directives');
  dbms_output.put_line('***************');

  open :c_result for
    select
      count(*)                                    nbr_directives
    from
      dba_sql_plan_dir_objects          pdo
        join dba_sql_plan_directives    pd
          on ( pdo.directive_id = pd.directive_id
             )
    where
      --filter the CBO directives on the given owner and table name
      pdo.owner = '&_owner'
      and pdo.object_name = '&_table_name'  
    ;

END;
/

BEGIN

  open :c_result for
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
      --filter the CBO directives on the given owner and table name
      pdo.owner = '&_owner'
      and pdo.object_name = '&_table_name'  
    group by
      pd.type,
      pd.enabled,
      pd.state
    order by
      pd.type,
      pd.enabled,
      pd.state
    ;

END;
/


break on directive_id skip page

BEGIN

  if upper('&_cbo_directives') = 'YES'
  then

    dbms_output.new_line;
    dbms_output.new_line;
    dbms_output.put_line('Directive Details');
    dbms_output.put_line('------------------');
  
      open :c_result for
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
          --filter the CBO directives on the given owner and table name
          pdo.owner = '&_owner'
          and pdo.object_name = '&_table_name'
        order by 
          pd.directive_id,
          pdo.object_type, 
          pdo.object_name, 
          pdo.subobject_name
        ;

    else
    
      open :c_result for
        select
          *
        from
          dual
        where
          1 = 0
        ;

    end if;

END;
/

clear breaks



prompt

-- cleanup the environment
undefine _owner
undefine _table_name
undefine _table_stats
undefine _tab_part_name
undefine _tab_subpart_name
undefine _column_stats
undefine _index_stats
undefine _index_name
undefine _ind_part_name
undefine _ind_subpart_name
undefine _cbo_directives
undefine _default_owner

set autoprint off

-- the end
