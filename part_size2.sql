set lines 300


column owner format a30
column table_name format a30
column partition_name format a30
column subpartition_name format a30
column segment_type for a20
column mb for 999G999G999D9

--compute sum of mb on partition_name 
compute sum of mb on report
--break on partition_name duplicates on report
break on report

undef owner
undef table_name

with 
all_partitions as
( select
    tpart.table_owner,
    tpart.table_name,
    tpart.partition_position,
    tpart.partition_name,
    tsub.subpartition_position,
    tsub.subpartition_name,
--    nvl(tsub.tablespace_name, tpart.tablespace_name)               tablespace_name,
--    nvl(tsub.compression, tpart.compression)                       compression,
    nvl(tsub.compress_for, tpart.compress_for)                     compress_for
  from
    dba_tab_partitions                      tpart
    left outer join dba_tab_subpartitions   tsub
      on ( tpart.table_owner = tsub.table_owner
           and tpart.table_name = tsub.table_name
           and tpart.partition_name = tsub.partition_name
         )
  where
    tpart.table_owner = '&&owner'
    and tpart.table_name = '&&table_name'
)
select 
  seg.owner, 
  seg.segment_name                  table_name,
--  part.partition_position,
  part.partition_name,
--  part.subpartition_position,
  part.subpartition_name,
--  seg.segment_type,
  seg.tablespace_name,
--  part.compression,
  part.compress_for,
  bytes/1024/1024                   mb
from 
  dba_segments                           seg
    left outer join all_partitions       part
      on ( seg.owner = part.table_owner
           and seg.segment_name = part.table_name
           and ( seg.partition_name = part.partition_name
                 or seg.partition_name = part.subpartition_name
               )
         )
where 
  seg.owner = '&&owner'
  and segment_name = '&&table_name'
order by 
  part.partition_position nulls last,
  part.subpartition_position nulls last
;

clear computes
clear breaks

undef owner
undef table_name
