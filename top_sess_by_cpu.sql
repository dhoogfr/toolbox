select *
from ( select C.sid, C.serial#, A.value, C.program
       from v$sesstat A, v$statname B, v$session C
       where A.statistic# = B.statistic#
             and B.name = 'CPU used by this session'
             and A.sid = C.sid
       order by value desc
     ) 
where rownum <= 10;