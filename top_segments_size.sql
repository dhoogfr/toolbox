/* Get the biggest 10 tables/indexes per tablespace
*/

set linesize 120
set pagesize 9999
column owner format a25
column segment_name format a30
column mb format 9G999G990D999
column tablespace_name format a25
column rn format 99
column segment_type format a15
break on tablespace_name skip 1

select tablespace_name, segment_type, owner, segment_name, bytes/1024/1024 mb, rn
from ( select tablespace_name, segment_type, owner, segment_name, bytes,
              row_number () 
                over ( partition by tablespace_name
                       order by bytes desc
                     ) rn
       from dba_segments
--       where segment_type in ('TABLE', 'INDEX')
--             and tablespace_name in 
       where tablespace_name in 
                ( select tablespace_name
                  from dba_tablespaces
                  where contents = 'PERMANENT'
                )
     )
where rn <= 10
order by tablespace_name, rn;