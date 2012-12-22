set lines 155
compute sum of totalsize_megs on report
break on report
col owner for a10
col segment_name for a20
col segment_type for a10
col totalsize_megs for 999,999.9
col compression_ratio for 999.9 
select owner, segment_name, segment_type type,
sum(bytes/1024/1024) as totalsize_megs,
&original_size/sum(bytes/1024/1024) as compression_ratio
from dba_segments
where owner like nvl('&owner',owner)
and segment_name like nvl('&table_name',segment_name)
and segment_type like nvl('&type',segment_type)
group by owner, segment_name, tablespace_name, segment_type
order by 5;
