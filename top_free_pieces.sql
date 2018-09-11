column free_mb format 999G999G999D99
select *
from ( select bytes/1024/1024 free_mb
       from dba_free_space
       where tablespace_name = '&1'
       order by free_mb desc
     )
where rownum <= 10;
