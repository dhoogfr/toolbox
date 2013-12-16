-- show information about a partitoned table
-- TODO: format the output

set linesize 250

column interval format a40

select
  owner,
  table_name,
  partitioning_type,
  subpartitioning_type,
  status,
  interval
from 
  dba_part_tables
where
  owner = '&&OWNER'
  and table_name = '&&TABLE'
;

column_name format a30
column column_position format 99999

select
  column_position,
  column_name
from
  dba_part_key_columns
where
  owner = '&&OWNER'
  and name = '&&TABLE'
order by
  column_position
;

select
  column_position,
  column_name
from
  dba_subpart_key_columns
where
  owner = '&&OWNER'
  and name = '&&TABLE'
order by
  column_position
;
 

column high_value format a90
column interval format a3
column subpartition_count format 9999999 heading "#SubPart"

select
  part.partition_name,
  part.composite,
  part.subpartition_count,
  part.high_value,
  part.partition_position,
  part.tablespace_name,
  part.compression,
  part.compress_for,
  part.interval,
  part.segment_created,
  (seg.bytes/1024/1024) MB
from
  dba_tab_partitions part,
  dba_segments seg
where
  part.table_owner = seg.owner(+)
  and part.table_name = seg.segment_name(+)
  and part.partition_name = seg.partition_name(+)
  and part.table_owner = '&&OWNER'
  and part.table_name = '&&TABLE'
order by
  part.partition_position
;



column high_value format a90
column interval format a3
column subpartition_position format 99999

break on partition_name

select
  spart.partition_name,
  spart.subpartition_name,
  spart.high_value,
  spart.subpartition_position,
  spart.tablespace_name,
  spart.compression,
  spart.compress_for,
  spart.interval,
  spart.segment_created,
  (seg.bytes/1024/1024) MB
from
  dba_tab_subpartitions spart,
  dba_tab_partitions part,
  dba_segments seg
where
  spart.table_owner = part.table_owner
  and spart.table_name = part.table_name
  and spart.partition_name = part.partition_name
  and spart.table_owner = seg.owner(+)
  and spart.table_name = seg.segment_name(+)
  and spart.partition_name = seg.partition_name(+)
  and spart.table_owner = '&&OWNER'
  and spart.table_name = '&&TABLE'
order by
  part.partition_position,
  spart.subpartition_position
;

clear breaks

undef OWNER
undef TABLE
