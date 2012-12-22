set lines 155
compute sum of totalsize_megs on report
break on report
col owner for a20
col segment_name for a30
col segment_type for a10
col totalsize_megs for 999,999.9
select * from (
select owner, segment_name, segment_type type,
sum(bytes/1024/1024) as totalsize_megs,
tablespace_name
from dba_segments
where owner like nvl('&owner',owner)
and segment_name like nvl('&table_name',segment_name)
and segment_type like nvl('&type',segment_type)
group by owner, segment_name, tablespace_name, segment_type
order by 4 desc
)
where rownum < 30
order by 4;
