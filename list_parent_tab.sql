set linesize 150
set verify off

column c_constraint_name format a20
column c_column_name format a25
column p_owner format a15
column p_constraint_name format a20
column p_table_name format a20
column p_column_name format a25

break on p_owner on p_table_name skip 1 on p_constraint_name on c_constraint_name

select
  con.r_owner p_owner, p_col.table_name p_table_name, con.r_constraint_name p_constraint_name, 
  con.constraint_name c_constraint_name, p_col.column_name p_column_name, 
  c_col.column_name c_column_name
from
  dba_constraints   con,
  dba_cons_columns  c_col,
  dba_cons_columns  p_col
where
  con.owner = c_col.owner
  and con.constraint_name = c_col.constraint_name
  and con.r_owner = p_col.owner
  and con.r_constraint_name = p_col.constraint_name
  and c_col.position = p_col.position
  and con.constraint_type = 'R'
  and con.owner = '&CHILD_TABLE_OWNER'
  and con.table_name = '&CHILD_TABLE_NAME'
order by
  p_owner, p_table_name, p_constraint_name, p_col.position, 
  c_constraint_name, c_col.position
;

clear breaks
