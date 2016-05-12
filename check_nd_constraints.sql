-- check for non deferrable unique/primary constraints that are supported by non unique indexes
-- because of the wide output it is best to spool it

set linesize 200

column owner format a30

break on owner skip 1 on table_name

select con.owner, con.table_name, con.constraint_name, con.constraint_type, index_owner, con.index_name
from dba_indexes ind,
     dba_constraints con
where ind.owner = con.index_owner
      and ind.index_name = con.index_name
      and ind.uniqueness != 'UNIQUE'
      and con.constraint_type in ('U', 'P')
      and con.deferrable = 'NOT DEFERRABLE'
order by con.owner, con.table_name, con.constraint_name;

clear breaks


column column_name format a30
column column_position format 99 heading CP
column uniqueness format a1 heading U
column index_type format a10

break on owner skip 1 on table_name on index_name on index_type on uniqueness on status

select ind.owner, ind.table_name, ind.index_name, ind.index_type, decode(ind.uniqueness,'UNIQUE', 'Y', 'N') uniqueness, 
       ind.status, inc.column_name, inc.column_position, ine.column_expression
from dba_indexes ind, dba_ind_columns inc, dba_ind_expressions ine
where ind.owner = inc.index_owner
      and ind.index_name = inc.index_name
      and inc.index_owner = ine.index_owner(+)
      and inc.index_name = ine.index_name(+)
      and inc.column_position = ine.column_position(+)
      and (ind.owner, ind.index_name) in
        ( select con.index_owner, con.index_name
          from dba_indexes ind,
               dba_constraints con
          where ind.owner = con.index_owner
                and ind.index_name = con.index_name
                and ind.uniqueness != 'UNIQUE'
                and con.constraint_type in ('U', 'P')
                and con.deferrable = 'NOT DEFERRABLE'
        )
order by ind.owner, ind.table_name, ind.index_name, inc.column_position;
        
clear breaks


set long 30

column constraint_name format a30
column constraint_type format a2 heading CT
column column_name format a30
column position format 99 heading CP


break on owner skip 1 on table_name on constraint_name on constraint_type on status

select con.owner, con.table_name, con.constraint_name, con.constraint_type, con.status, col.column_name, col.position
from dba_constraints con,
     dba_cons_columns col,
     dba_indexes ind
where col.owner = con.owner
      and col.constraint_name = con.constraint_name
      and ind.owner = con.index_owner
      and ind.index_name = con.index_name
      and ind.uniqueness != 'UNIQUE'
      and con.constraint_type in ('U', 'P')
      and con.deferrable = 'NOT DEFERRABLE'
order by con.owner, con.table_name, con.constraint_name, col.position;


clear breaks
