set linesize 150
column username format a30
column logon format a20,
column idle format a15
column program format a30

select sid, username, to_char(logon_time, 'DD/MM/YYYY HH24:MI:SS') logon, last_call_et,
       floor(last_call_et/3600)||':'|| floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) idle,
       program
from v$session
where status = 'INACTIVE'
      and username is not null
order by last_call_et;