set linesize 130
set pagesize 9999

break on statistic_name skip 1

column tablespace_name format a20
column object_type format a10
column object_name format a30
column statistic_name format a34
column owner format a15
column rn format 99

select statistic_name, value, rn,owner, object_name, object_type, tablespace_name
from ( select owner, object_name, object_type, tablespace_name,
              statistic_name, value,
              dense_rank() over
                ( partition by statistic_name
                  order by value desc
                ) rn
       from v$segment_statistics
     )
where rn <= 5
      and value != 0
order by statistic_name, value desc, owner, object_name, object_type;