set linesize 300
set long 100
set verify off

column index_name format a30
column column_name format a30
column column_position format 99 heading CP
column uniqueness format a1 heading U
column visibility format a10
column column_expression format a50
column descend format a10
column part_type format a12
column subpart_type format a12
column locality format a10
column alignment format a12

break on index_name skip 1 on index_type on uniqueness on status on visibility on part_type on subpart_type on locality on alignment

select
  ind.index_name,
  ind.index_type,
  decode(ind.uniqueness,'UNIQUE', 'Y', 'N') uniqueness,
  ind.status,
  ind.visibility,
  pin.partitioning_type as part_type,
  pin.subpartitioning_type as subpart_type,
  pin.locality,
  pin.alignment,
  inc.column_name,
  inc.column_position,
  inc.descend,
  ine.column_expression
from
  dba_indexes                 ind
    join dba_ind_columns      inc
      on ( ind.owner = inc.index_owner
           and ind.index_name = inc.index_name
         )
    left outer join dba_part_indexes  pin
      on ( ind.owner = pin.owner
           and ind.index_name = pin.index_name
         )
    left outer join dba_ind_expressions   ine
      on ( inc.index_owner = ine.index_owner
           and inc.index_name = ine.index_name
           and inc.column_position = ine.column_position
         )
where
  ind.table_owner = '&T_OWNER'
  and ind.table_name = '&T_NAME'
  and ind.dropped = 'NO'
order by
  ind.index_name,
  inc.column_position
;

clear breaks
set verify on
