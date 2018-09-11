set linesize 150
set pagesize 999
column sid format 9999
column machine format a20
column osuser format a20
column user format a15
column program format a30

select sid, serial#, username, machine, osuser, program, server, last_call_et
from v$session
where username is not null;
