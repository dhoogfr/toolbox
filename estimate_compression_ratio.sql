-- uses the statistics data to estimate the compression ratio of OLTP / HCC compressed table partitions
-- for this it estimates the uncompressed table size by multiplying the average row length with the number of rows and devide the result by the block size
-- to get the current (compressed) table size, the number of blocks (as stored by the cbo) is multiplied by the block size, rather then getting it from dba_segments.
-- this to avoid errors when the cbo statistics are stale (as the calculation for the compressed and uncompressed size are based upon the same data)

column compress_for format a20 heading "compression method"
column max_compr_size_mb format 9G999G999D99 heading "max|compressed size (MB)"
column min_compr_size_mb format 9G999G999D99 heading "min|compressed size (MB)"
column avg_compr_size_mb format 9G999G999D99 heading "avg|compressed size (MB)"
column max_uncompr_size_mb format 999G999G999D99 heading "max|uncompressed size (MB)"
column min_uncompr_size_mb format 999G999G999D99 heading "min|uncompressed size (MB)"
column avg_uncompr_size_mb format 999G999G999D99 heading "avg|uncompressed size (MB)"
column max_pct_compression format 990D00 heading "max|% compression"
column min_pct_compression format 990D00 heading "min|% compression"
column avg_pct_compression format 990D00 heading "avg|% compression"
column nbr_samples format 9G999G999 heading "# samples"

select 
  prt.compress_for,
  max(prt.avg_row_len * prt.num_rows)/1024/1024 max_uncompr_size_mb,
  min(prt.avg_row_len * prt.num_rows)/1024/1024 min_uncompr_size_mb,
  avg(prt.avg_row_len * prt.num_rows)/1024/1024 avg_uncompr_size_mb,
  max(prt.blocks * tbs.block_size)/1024/1024 max_compr_size_mb,
  min(prt.blocks * tbs.block_size)/1024/1024 min_compr_size_mb,
  avg(prt.blocks * tbs.block_size)/1024/1024 avg_compr_size_mb,
  max(100 - (100 / (prt.avg_row_len * prt.num_rows)) * (prt.blocks * tbs.block_size)) max_pct_compression,
  min(100 - (100 / (prt.avg_row_len * prt.num_rows)) * (prt.blocks * tbs.block_size)) min_pct_compression,
  avg(100 - (100 / (prt.avg_row_len * prt.num_rows)) * (prt.blocks * tbs.block_size)) avg_pct_compression,
  count(*) nbr_samples
from 
  dba_tab_partitions    prt,
  dba_tablespaces       tbs
where 
  prt.tablespace_name = tbs.tablespace_name
  -- only compressed partitions
  and prt.compress_for in ('OLTP', 'QUERY LOW', 'QUERY HIGH', 'ARCHIVE LOW', 'ARCHIVE HIGH')
  -- no subpartitioned tables
  and prt.subpartition_count = 0   
  -- only partitions that are analyzed
  and prt.last_analyzed is not null
  -- filter out empty partitions
  and prt.avg_row_len > 0
  and prt.num_rows > 0
  and prt.blocks > 0
  -- filter out too small tables (less than 100MB worth of blocks), as they skew up the result
  and prt.blocks >= (104857600 / tbs.block_size)
  -- filter out tables that are compressed not smaller than uncompressed (perhaps compression enabled after loading and not yet moved?)
  and (100 / (prt.avg_row_len * prt.num_rows)) * (prt.blocks * tbs.block_size) < 100
group by
  prt.compress_for
order by
  prt.compress_for
/
