-- report on the number of compressed objects (per owner, object_type and compression type)

column owner format a30
column object_type format a20
column compress_for format a30
column counted format 9G999G999G999

break on owner skip 1 on page

select
  owner,
  compress_for, 
  object_type,
  count(*)  counted
from
  ( select
      owner,
      'TABLE' as object_type,
      compress_for 
    from
      dba_tables
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
    union all
    select
      table_owner,
      'TABLE_PART' as object_type,
      compress_for
    from
      dba_tab_partitions
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
      and compression != 'NONE'
    union all
    select
      table_owner,
      'TABLE_SUBPART' as object_type,
      compress_for
    from
      dba_tab_subpartitions
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
    union all
    select
      owner,
      'INDEX' as object_type,
      decode(compression, 'ENABLED', 'BASIC', compression)
    from
      dba_indexes
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
    union all
    select
      index_owner,
      'INDEX_PART' as object_type,
      decode(compression, 'ENABLED', 'BASIC', compression)
    from
      dba_ind_partitions
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
      and compression != 'NONE'
    union all
    select
      index_owner,
      'INDEX_SUBPART' as object_type,
      decode(compression, 'ENABLED', 'BASIC', compression)
    from
      dba_ind_subpartitions
    where
      nvl(compression, 'DISABLED') != 'DISABLED'
  )
group by
  owner,
  object_type,
  compress_for
order by
  owner,
  compress_for,
  object_type
;

clear computes
clear breaks
