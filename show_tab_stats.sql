set verify off

set linesize 200
set pages 9999


column data_type format a12
column num_rows format 999G999G999
column num_nulls format 999G999G999
column sample_size format 999G999G999
column num_distinct format 999G999G999
column num_buckets format 999 heading BUC#
column density format 0D999999999

select
  tab.last_analyzed, tab.num_rows, tab.sample_size, tab.stale_stats
from
  dba_tab_statistics    tab
where
  tab.owner = '&&TABLE_OWNER'
  and tab.table_name = '&&TABLE_NAME'
;

column data_type format a12
column num_rows format 999G999G999
column num_nulls format 999G999G999
column sample_size format 999G999G999
column num_distinct format 999G999G999
column num_buckets format 999 heading BUC#
column density format 0D999999999

select
  col.column_name, col.last_analyzed, col.data_type, tab.num_rows, col.num_nulls, 
  col.sample_size, col.num_distinct, col.histogram, num_buckets, col.density
from
  dba_tables        tab,
  dba_tab_columns   col
where
  tab.owner = col.owner
  and tab.table_name = col.table_name
  and tab.owner = '&&TABLE_OWNER'
  and tab.table_name = '&&TABLE_NAME'
order by
  col.column_id
;

undefine TABLE_OWNER
undefine TABLE_NAME
