set verify off

set linesize 150

column table_owner format a30
column table_name format a30
column index_owner format a30
column index_name format a30

select obj_t.owner table_owner,
       obj_t.object_name table_name,
       obj_i.owner index_owner,
       obj_i.object_name index_name
from dba_objects obj_t,
     dba_objects obj_i,
     sys.ind$ ind
where ind.bo# = obj_t.object_id
      and ind.obj# = obj_i.object_id
      and bitand(ind.property,4096) = 4096  -- index is system generated
      and bitand(ind.property,1) = 1        -- index is unique
      and obj_i.owner = '&OWNER'
order by table_name, index_name;
