set linesize 300
set long 30
set verify off

column index_name format a30
column column_name format a30
column column_position format 99 heading CP
column uniqueness format a1 heading U

break on index_name on index_type on uniqueness on status skip 1

select ind.index_name, ind.index_type, decode(ind.uniqueness,'UNIQUE', 'Y', 'N') uniqueness, ind.status, 
       inc.column_name, inc.column_position, ine.column_expression
from dba_indexes ind, dba_ind_columns inc, dba_ind_expressions ine
where ind.owner = inc.index_owner
      and ind.index_name = inc.index_name
      and inc.index_owner = ine.index_owner(+)
      and inc.index_name = ine.index_name(+)
      and inc.column_position = ine.column_position(+)
      and ind.table_owner = '&T_OWNER'
      and ind.table_name = '&T_NAME'
order by ind.index_name, inc.column_position;

clear breaks
set verify on
