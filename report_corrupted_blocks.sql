--- lists the corrupted blocks (as found by RMAN), with the owner and segment information (or indication if these are free blocks)
-- taken from blog post by Michael Dinh (https://www.pythian.com/blog/oracle-free-block-corruption-test-case/)

column owner format a30 heading "Owner"
column segment_type format a25 heading "Segment Type"
column segment_name format a30 heading "Segment Name"
column partition_name format a30 heading "Partition"
column file# format 9999999 heading "File"
column s_blk# format 999999 heading "Start|Block"
column e_dblk# format 999999 heading "End|Block"
column blk_corrupt format 999G999G999 heading  "Blocks|Corrupt"
column description format a15 heading "Description"

select 
  e.owner, 
  e.segment_name, 
  e.partition_name, 
  e.segment_type, 
  c.file#, 
  greatest(e.block_id, c.block#) s_blk#, 
  least(e.block_id+e.blocks-1, c.block#+c.blocks-1) e_dblk#, 
  least(e.block_id+e.blocks-1, c.block#+c.blocks-1) - greatest(e.block_id, c.block#) + 1 blk_corrupt, 
  null description
from
  dba_extents                   e, 
  v$database_block_corruption   c
where
  e.file_id = c.file#
  and e.block_id <= c.block# + c.blocks - 1 
  and e.block_id + e.blocks - 1 >= c.block#
union
select 
  s.owner, 
  s.segment_name, 
  s.partition_name, 
  s.segment_type, 
  c.file#,
  header_block s_blk#, 
  header_block e_blk#, 
  1 blk_corrupt, 
  'Segment Header' description
from 
  dba_segments                  s, 
  v$database_block_corruption   c
where
  s.header_file = c.file#
  and s.header_block between c.block# and c.block# + c.blocks - 1
union
SELECT
  null owner, 
  null segment_name, 
  null partition_name, 
  null segment_type, 
  c.file#, 
  greatest(f.block_id, c.block#) s_blk#, 
  least(f.block_id+f.blocks-1, c.block#+c.blocks-1) e_blk#, 
  least(f.block_id+f.blocks-1, c.block#+c.blocks-1)- greatest(f.block_id, c.block#) + 1 blk_corrupt, 
  'Free Block' description
from 
  dba_free_space                f, 
  v$database_block_corruption   c
where 
  f.file_id = c.file#
  and f.block_id <= c.block# + c.blocks - 1
  and f.block_id + f.blocks - 1 >= c.block#
order by 
  owner nulls last,
  segment_name nulls last,
  partition_name nulls last,
  file#, 
  s_blk#
;
