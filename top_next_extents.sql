column curr_mb format 999G999G999D99
column next_mb format 999G999D99

select *
from ( select segment_name, segment_type, round(bytes/1024/1024,2) curr_mb, 
              round(next_extent/1024/1024,2) next_mb, pct_increase
       from dba_segments
       where tablespace_name = '&1'
       order by next_mb desc
     )
where rownum <= 10;

