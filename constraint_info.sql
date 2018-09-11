set verify off

set linesize 300
set long 30

column constraint_name format a30
column constraint_type format a2 heading CT
column column_name format a30
column position format 99 heading CP
column r_owner format a30
column r_constraint_name format a30

break on constraint_name skip 1 on constraint_type

select con.constraint_name, con.constraint_type, con.status, con.r_owner, con.r_constraint_name, 
       col.column_name, col.position, con.search_condition
from dba_constraints con,
     dba_cons_columns col
where col.owner = con.owner
      and col.constraint_name = con.constraint_name
      and con.owner = '&T_OWNER'
      and con.table_name = '&T_NAME'
order by con.constraint_name, col.position;


clear breaks
