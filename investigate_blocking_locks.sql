
-- who is blocked
set linesize 120
column lmode format 99 heading LM
column request format 99 heading RQ

select A.sid, serial#, B.type, lmode, request, block, ctime, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#
from v$session A, v$lock B
where A.sid = B.sid
      and lockwait is not null
order by A.sid, B.type;


-- who is blocking
select A.sid, serial#, B.type, lmode, request, block, ctime, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#
from v$session A, v$lock B
where A.sid = B.sid
      and A.sid in 
        ( select sid 
          from v$lock 
          where block != 0
        )
order by A.sid, B.type;


-- blocking session info
set linesize 170
set verify off

column username format a20
column program format a15
column osuser format a15
column machine format a25
column inac format a10

select sess.sid, sess.serial#, sess.username, sess.program, sess.osuser, 
       sess.machine, sess.sql_id, sess.sql_child_number, 
       extract(hour from (systimestamp + last_call_et/24/60/60 - systimestamp)) || ':' ||
       extract(minute from (systimestamp + last_call_et/24/60/60 - systimestamp))  || ':' ||
       round(extract(second from (systimestamp + last_call_et/24/60/60 - systimestamp))) inac
from v$session sess
where sess.sid in 
        ( select sid 
          from v$lock 
          where block != 0
        )
order by sess.sid;

-- object involved
select object_type, owner, object_name
from dba_objects
where object_id = &1;

-- which sql statement (current sql, not necessary the statement that caused the lock)
select sql_text
from v$sqltext_with_newlines
where (address, hash_value)
        = ( select sql_address, sql_hash_value
            from v$session
            where sid = &sid
          )
order by piece;

