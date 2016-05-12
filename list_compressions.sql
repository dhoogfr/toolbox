set verify off

column counted format 9G999G999
column mb format 9G999G999G999D99

compute sum of counted on owner
compute sum of counted on report
compute sum of mb on owner
compute sum of mb on report

break on owner on report

with tabseg as
( select
    tab.owner, 
    tab.compression,
    tab.compress_for,
    seg.bytes
  from
    dba_tables                tab,
    dba_segments              seg
  where
    tab.owner = seg.owner
    and tab.table_name = seg.segment_name
    and tab.partitioned = 'NO'
    and seg.tablespace_name = '&&tbs'
  union all
  select
    part.table_owner, 
    part.compression,
    part.compress_for,
    seg.bytes
  from
    dba_tab_partitions        part,
    dba_segments              seg
  where
    part.table_owner = seg.owner
    and part.table_name = seg.segment_name
    and part.partition_name = seg.partition_name
    and part.subpartition_count = 0
    and seg.tablespace_name = '&&tbs'
  union all
  select
    spart.table_owner, 
    spart.compression,
    spart.compress_for,
    seg.bytes
  from
    dba_tab_subpartitions     spart,
    dba_segments              seg
  where
    spart.table_owner = seg.owner
    and spart.table_name = seg.segment_name
    and spart.subpartition_name = seg.partition_name
    and seg.tablespace_name = '&&tbs'
)
select
  owner,
  compression,
  compress_for,
  count(*) counted,
  sum(bytes)/1024/1024 MB
from
  tabseg
group by
  owner,
  compression,
  compress_for
order by
  owner,
  compression,
  compress_for
;

undef tbs
