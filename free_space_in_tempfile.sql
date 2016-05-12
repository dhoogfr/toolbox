col size_temp_files format 999G999G999G999 Heading "Size|Temp|Files"
col free_space_in_temp_files format 999G999G999G999 Heading "Free|Space|In|Temp|Files"
col free_space_in_sort_segment format 999G999G999G999 Heading "Free|Space|In|Sort|Segment"
col used_space_in_sort_segment format 999G999G999G999 Heading "Used|Space|In|Sort|Segment"
col total_free format 999G999G999G999 Heading "Total|Free"

select tsh.tablespace_name,
       dtf.omvang size_temp_files,
       tsh.free_space_space_header free_space_in_temp_files,
       nvl(ss.free_space_sort_segment,tsh.used_space_space_header) free_space_in_sort_segment, -- could be empty
       nvl(ss.used_space_sort_segment,0) used_space_in_sort_segment,
       tsh.free_space_space_header+nvl(ss.free_space_sort_segment,tsh.used_space_space_header) TOTAL_FREE
from ( select tablespace_name, 
              sum(bytes)/1024/1024 omvang 
       from dba_temp_files
       group by tablespace_name
     ) dtf,
     ( select tablespace_name,
              sum(BYTES_USED)/1024/1024 USED_SPACE_SPACE_HEADER,
              sum(BYTES_FREE)/1024/1024 FREE_SPACE_SPACE_HEADER
       from v$temp_space_header
       group by tablespace_name
     ) tsh,
     ( select tablespace_name,
              sum(USED_BLOCKS)/1024/1024 USED_SPACE_SORT_SEGMENT,
              sum(FREE_BLOCKS)* par.value/1024/1024  FREE_SPACE_SORT_SEGMENT
       from v$sort_segment ss,
            v$parameter par
       where par.name = 'db_block_size'
       group by tablespace_name, value
     ) ss
where dtf.tablespace_name = tsh.tablespace_name
      and ss.tablespace_name (+)  = dtf.tablespace_name 
/




