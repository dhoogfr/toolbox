set linesize 150
column owner format a20
column index_type format a15
column partition_name format a15
column subpartition_name format a15

select ind.owner,ind.index_name, ind.index_type, inp.partition_name, inps.subpartition_name,
       ind.status index_status, inp.status part_status, inps.status subpart_status
from dba_indexes ind, dba_ind_partitions inp, dba_ind_subpartitions inps 
where ind.index_name = inp.index_name(+)
      and ind.owner = inp.index_owner(+)
      and inp.index_name  = inps.index_name(+)
      and inp.index_owner = inps.index_owner(+)
      and inp.partition_name = inps.partition_name(+)
      and ind.table_owner='&owner'
      and ind.table_name = '&table_name'
order by 1,2,4,5;

