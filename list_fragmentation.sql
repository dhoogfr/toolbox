/*  
   gives the total_amount of mb free space and the 10 biggest extents
   per tablespace of type PERMANENT (with the number of times this extent size extists)

   This query can be used to verify the fragmentation of a tablespace
*/

set linesize 120
set pagesize 9999
column tablespace_name format a30
column total_free_mb format 9G999G990D999
column extent_mb format 9G999G990D999
column counted format 9G999G990
break on tablespace_name skip 1 on total_free_mb

select A.tablespace_name, total_free/1024/1024 total_free_mb, bytes/1024/1024 extent_MB, 
       counted
from ( select tablespace_name, bytes, counted,
              row_number()
                over ( partition by tablespace_name
                       order by bytes desc
                     ) rn
       from ( select A.tablespace_name, A.bytes , count(*) counted
              from dba_free_space A, dba_tablespaces B
              where A.tablespace_name = B.tablespace_name
                    and B.contents = 'PERMANENT'
              group by A.tablespace_name, bytes
            )
     ) A, 
     ( select tablespace_name, sum(bytes) total_free
       from dba_free_space
       group by tablespace_name
     ) B
where A.tablespace_name = B.tablespace_name
      and A.rn <= 10
order by tablespace_name, rn;
