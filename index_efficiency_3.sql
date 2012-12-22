rem
rem     Script:        index_efficiency_3.sql
rem     Author:        Jonathan Lewis
rem     Dated:         Sept 2003
rem     Purpose:       Example of how to check leaf block packing
rem
rem	Last tested
rem		11.1.0.7
rem		10.2.0.3
rem		 9.2.0.8
rem	Not tested
rem		11.2.0.1
rem		10.2.0.4
rem	Not applicable
rem		 8.1.7.4	-- no sys_op_lbid()
rem
rem     Notes
rem     Example of analyzing index entries per leaf block.
rem
rem	Set up the schema, table name, and index name before
rem	running the query.
rem
rem	The code assumes you have no more than 10 columns in
rem	the index for the purposes of generating "is not null"
rem	clauses to force the necessary index-only execution path.
rem	This limit can easily be extended by cloning and editing
rem	the lines of the "setup" statement.
rem
rem	For a simple b-tree index, the first parameter to the
rem	sys_op_lbid() function has to be the object_id of the
rem	index.
rem
rem	The query will work with a sample clause if you are
rem	worried that the index you want to investigate is too
rem	large to analyze in a reasonable time. (I take 100 blocks
rem	per second as a conservative estimate for the I/O rate
rem	when running this script on very large indexes but have
rem	seen it running three or four times faster that.)
rem
rem	This version of the code is suitable only for simple
rem	B-tree indexes - although that index may be reversed,
rem	have descending columns or virtual (function-based)
rem	columns, or be a global index on a partitioned table.
rem

define m_owner = &m_schema
define m_table_name = &m_table
define m_index_name = &m_index

column ind_id new_value m_ind_id

select
        object_id ind_id
from
        dba_objects
where
        owner       = upper('&m_owner')
and     object_name = upper('&m_index_name')
and     object_type = 'INDEX'
;

column col01    new_value m_col01
column col02    new_value m_col02
column col03    new_value m_col03
column col04    new_value m_col04
column col05    new_value m_col05
column col06    new_value m_col06
column col07    new_value m_col07
column col08    new_value m_col08
column col09    new_value m_col09

select
        nvl(max(decode(column_position, 1,column_name)),'null')        col01,
        nvl(max(decode(column_position, 2,column_name)),'null')        col02,
        nvl(max(decode(column_position, 3,column_name)),'null')        col03,
        nvl(max(decode(column_position, 4,column_name)),'null')        col04,
        nvl(max(decode(column_position, 5,column_name)),'null')        col05,
        nvl(max(decode(column_position, 6,column_name)),'null')        col06,
        nvl(max(decode(column_position, 7,column_name)),'null')        col07,
        nvl(max(decode(column_position, 8,column_name)),'null')        col08,
        nvl(max(decode(column_position, 9,column_name)),'null')        col09
from
        dba_ind_columns
where   table_owner = upper('&m_owner')
and     table_name  = upper('&m_table_name')
and     index_name  = upper('&m_index_name')
order by
        column_position
;

break on report skip 1
compute sum of blocks on report
compute sum of row_ct on report

spool index_efficiency_3

prompt Owner &m_owner
prompt Table &m_table_name
prompt Index &m_index_name

set verify off

select
        rows_per_block,
        blocks,
        rows_per_block * blocks                     row_ct,
        sum(blocks) over (order by rows_per_block)  cumulative_blocks
from    (
        select
                rows_per_block,
                count(*) blocks
        from    (
                select
                        /*+
                               cursor_sharing_exact
                               dynamic_sampling(0)
                               no_monitoring
                               no_expand
                               index_ffs(t1, &m_index_name)
                               noparallel_index(t1, &m_index_name)
                        */
                        sys_op_lbid( &m_ind_id ,'L',t1.rowid) as block_id,
                        count(*)                              as rows_per_block
                from
                        &m_owner..&m_table_name t1
                --      &m_owner..&m_table_name sample block (5) t1
                where
                        &m_col01 is not null
                or      &m_col02 is not null
                or      &m_col03 is not null
                or      &m_col04 is not null
                or      &m_col05 is not null
                or      &m_col06 is not null
                or      &m_col07 is not null
                or      &m_col08 is not null
                or      &m_col09 is not null
                group by
                        sys_op_lbid( &m_ind_id ,'L',t1.rowid)
                )
        group by
                rows_per_block
        )
order by
        rows_per_block
;

spool off
