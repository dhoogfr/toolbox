set linesize 120
column username format a30
column logon format a20
column idle format a15
column program format a30
column status format a1 trunc

select *
from ( select A.sid, consistent_gets, B.username, B.logon_time, B.program, B.status, 
       floor(last_call_et/3600)||':'|| floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) idle
       from v$sess_io A, v$session B
       where A.sid= B.sid
             and program not like 'oracle@v880%'
       order by consistent_gets desc
     )
where rownum <= 20
order by consistent_gets desc;
