set lines 155
compute sum of totalsize_megs on report
break on report on owner on segment_name
col owner for a20
col segment_name for a20
col part_name for a20
col segment_type for a10
col totalsize_megs for 999,999.9
select s.owner, segment_name, t.partition_name part_name,
sum(bytes/1024/1024) as totalsize_megs, compress_for
from dba_segments s, dba_tab_partitions t
where s.owner = t.table_owner
and t.table_name = s.segment_name
and s.owner like nvl('&owner',s.owner)
and segment_name like nvl('&table_name',segment_name)
group by s.owner, segment_name, t.partition_name, compress_for
order by 3;
