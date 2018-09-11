set linesize 150

column owner format a20
column file_name format a60
column file_id format 999 heading ID
column high_water_mark format 99G999D99 heading HWM
column segment_type format a15

break on file_id skip 1 on file_name

with
maxext as
( select /*+ MATERIALIZE */
         file_id, owner, block_id, blocks, segment_name, segment_type, ranking
  from ( select file_id, owner, block_id, blocks, segment_name, segment_type,
                rank() over
                    ( partition by file_id 
                      order by (block_id + blocks -1) desc
                    ) ranking
         from dba_extents
         where tablespace_name = '&tablespace'
       )
  where ranking <= 5
)
select df.file_name, maxext.file_id, maxext.owner, maxext.segment_name, maxext.segment_type, 
       ((maxext.block_id + maxext.blocks - 1) * 8192 / 1024/1024) high_water_mark
from maxext, dba_data_files df
where df.file_id = maxext.file_id
order by maxext.file_id, ranking;
 

