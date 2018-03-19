--   calculates the sum of the ALLOCATED sizes for the given non partitioned tables
--   and their dependend indexes and lob segments

column mb format 9G999G999D99
column extents format 999G999D99
column blocks format 999G999G999D99

compute sum label total of mb on report
break on report

with my_segments
as
( select
    --+ MATERIALIZE
    tab.owner         table_owner, 
    tab.table_name, 
    ind.owner         index_owner, 
    ind.index_name,
    lob.segment_name  lob_segment,
    lob.index_name    lob_ind_segment
  from
    dba_tables                        tab
      left outer join dba_indexes     ind
        on ( tab.owner = ind.table_owner
             and tab.table_name = ind.table_name
           )
      left outer join dba_lobs       lob
        on ( tab.owner = lob.owner
             and tab.table_name = lob.table_name
           )
  where
    tab.owner = '&owner'
    and tab.table_name = '&table_name'
)
select
  segment_type, 
  sum(extents) extents, 
  sum(blocks) blocks, 
  sum(bytes)/1024/1024 mb
from
  dba_segments   dseg
where
  (owner,segment_name) in
    ( select
        seg.table_owner,
        seg.table_name
      from
        my_segments seg
    )
  or (owner,segment_name) in
    ( select
        seg.index_owner,
        seg.index_name
      from
        my_segments seg
    )
  or (owner, segment_name) in
    ( select
        seg.table_owner,
        seg.lob_segment
      from
        my_segments seg
    )
  or (owner, segment_name) in
    ( select
        seg.table_owner,
        seg.lob_ind_segment
      from
        my_segments seg
    )
group by
  segment_type
;


clear computes
clear breaks

undef owner
undef table_name
