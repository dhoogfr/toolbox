-- show information about a partitoned table

set verify off
set linesize 250

column owner format a30
column table_name format a30
column column_name format a30
column interval format a40
column high_value format a25
column interval format a3
column subpartition_count format 9999999 heading "#SUBPART"
column partition_name format a30
column subpartition_name format a30
column column_position format 99999
column interval format a3
column subpartition_position format 99999

accept OWNER prompt 'Owner: '
accept TABLE prompt 'Table Name: '


prompt
prompt ###basic info

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


prompt
prompt ###info on partition columns

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


prompt
prompt ###info on sub-partition columns

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


prompt
prompt ###details on partitions

compute sum of mb on report

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

clear computes


prompt
prompt ###details on sub-partitions

break on partition_name skip page duplicates
compute sum of mb on partition_name
compute sum of mb on report
/*
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
  and spart.subpartition_name = seg.partition_name(+)
  and spart.table_owner = '&&OWNER'
  and spart.table_name = '&&TABLE'
order by
  part.partition_position,
  spart.subpartition_position
;

*/

--switched to ansi join syntax (as excercise  ;-)  
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
  dba_tab_subpartitions                                       spart
    join dba_tab_partitions                                   part
      on ( part.table_owner = spart.table_owner
           and part.table_name = spart.table_name
           and part.partition_name = spart.partition_name
         )
      left outer join dba_segments                            seg
        on ( seg.owner = spart.table_owner
             and seg.segment_name = spart.table_name
             and seg.partition_name = spart.subpartition_name
           )
where
  spart.table_owner = '&&OWNER'
  and spart.table_name = '&&TABLE'
order by
  part.partition_position,
  spart.subpartition_position
;


clear breaks
clear computes


undef OWNER
undef TABLE

