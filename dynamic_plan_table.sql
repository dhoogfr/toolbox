create or replace view dynamic_plan_table
as
select rawtohex(address) || '_' || child_number as statement_id, sysdate timestamp,
       operation, options, object_node, object_owner, object_name, 0 object_instance,
       optimizer, search_columns, id, parent_id, position, cost, cardinality, bytes, 
       other_tag, partition_start, partition_stop, partition_id, other, distribution,
       cpu_cost, io_cost, temp_space, access_predicates, filter_predicates
from v$sql_plan;

