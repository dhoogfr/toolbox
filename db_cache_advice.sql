select size_for_estimate "Cache Size (MB)", 
       buffers_for_estimate "Buffers",
       estd_physical_read_factor "Estd Phys Read Factor", 
       estd_physical_reads "Estd Phys Reads"
from v$db_cache_advice
where name = 'DEFAULT'
      and block_size = 
        ( select value 
          from v$parameter 
          where name = 'db_block_size'
        )
      and advice_status = 'ON'
/
