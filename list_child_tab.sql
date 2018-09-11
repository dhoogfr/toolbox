set linesize 150
set verify off

column c_constraint_name format a20
column c_column_name format a25
column c_owner format a15
column p_constraint_name format a20
column c_table_name format a20
column p_column_name format a25

break on c_owner on c_table_name skip 1 on c_constraint_name on p_constraint_name

select
  con.owner c_owner, c_col.table_name c_table_name, con.constraint_name c_constraint_name, 
  con.r_constraint_name p_constraint_name, c_col.column_name c_column_name, 
  p_col.column_name p_column_name
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
  and p_col.owner = '&PARENT_TABLE_OWNER' 
  and p_col.table_name = '&PARENT_TABLE_NAME'
order by
  c_owner, c_table_name, c_constraint_name, c_col.position, 
  p_constraint_name, p_col.position
;

-- volgende werkt ook en is misschien beter te begrijpen, maar bovenstaand lijkt iets performanter
--with
--  ref_rel as
--    ( select
--        c_con.owner c_owner, c_con.constraint_name c_constraint_name,
--        p_con.owner p_owner, p_con.constraint_name p_constraint_name, 
--        c_con.table_name c_table_name
--      from
--        dba_constraints   c_con,
--        dba_constraints   p_con
--     where
--        c_con.r_owner = p_con.owner
--        and c_con.r_constraint_name = p_con.constraint_name
--        and c_con.constraint_type = 'R'
--        and p_con.owner = '&PARENT_TABLE_OWNER'
--        and p_con.table_name = '&PARENT_TABLE_NAME'
--    )
--select
--  ref_rel.c_owner, ref_rel.c_table_name, ref_rel.c_constraint_name, 
--  ref_rel.p_constraint_name, c_con_col.column_name c_column_name, 
--  p_con_col.column_name p_column_name
--from
--  ref_rel,
--  dba_cons_columns  c_con_col,
--  dba_cons_columns  p_con_col
--where
--  ref_rel.c_owner = c_con_col.owner
--  and ref_rel.c_constraint_name = c_con_col.constraint_name
--  and ref_rel.p_owner = p_con_col.owner
--  and ref_rel.p_constraint_name = p_con_col.constraint_name
--  and c_con_col.position = p_con_col.position
--order by
--  c_owner, c_table_name, c_constraint_name, c_con_col.position, 
--  p_constraint_name, p_con_col.position
--;

clear breaks
