DO NOT USE, CONTAINS ERRORS

--   calculates the sum of the ALLOCATED sizes for the given tables
--   and their dependend indexes and lob segments

column mb format 9G999G999D99
column extents format 999G999D99
column blocks format 999G999G999D99

compute sum label total of mb on report
break on report

with my_segments as
 ( select B.owner table_owner, B.table_name, c.owner index_owner, C.index_name, 
          D.segment_name lob_segment
   from dba_tables B, dba_indexes C, dba_lobs D
   where B.owner = C.table_owner(+) 
         and B.table_name = C.table_name(+)
         and B.owner = D.owner(+)
         and B.table_name = D.table_name(+)
         and B.table_name = 'EMAILS'
         and B.owner = 'TRIDION_CM_EMAIL'
 )
select segment_type, sum(extents) extents, sum(blocks) blocks, sum(bytes)/1024/1024 mb
from dba_segments, my_segments
where ( owner = my_segments.table_owner
        and segment_name = my_segments.table_name
      )
      or ( owner = my_segments.index_owner
           and segment_name = my_segments.index_name
         )
      or ( owner = my_segments.table_owner
           and segment_name = my_segments.lob_segment
         )
group by segment_type;