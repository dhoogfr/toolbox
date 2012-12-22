select A.tablespace_name, b_allocated/1024/1024 mb_allocated, b_max/1024/1024 mb_max,
       (b_free + (b_max - b_allocated))/1024/1024 mb_free, 
       round(((100 * (b_free + (b_max - b_allocated))) / b_max), 2) pct_free, 
       C.autoextensible
from ( select tablespace_name, sum(bytes) as b_free
       from dba_free_space
       group by tablespace_name
     ) B,
     ( select tablespace_name, sum(bytes) as b_allocated, sum(greatest(bytes, maxbytes)) b_max,
              max(autoextensible) autoextensible
       from dba_data_files
       group by tablespace_name
     ) C, dba_tablespaces A
where A.tablespace_name = B.tablespace_name
      and A.tablespace_name = C.tablespace_name
      and A.contents = 'PERMANENT'
 --     and round(((100 * (b_free + (b_max - b_allocated))) / b_max), 2) <= 20
order by pct_free asc;
