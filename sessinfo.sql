set linesize 150
set verify off

column username format a20
column program format a15
column osuser format a15
column machine format a25
column sql_id new_value v_sql_id
column sql_child_number new_value  v_sql_child_number

select sess.sid, sess.serial#, prc.spid, sess.username, sess.program, sess.osuser, 
       sess.machine, sess.sql_id, sess.sql_child_number
from v$session sess, v$process prc
where sess.paddr = prc.addr
      and prc.spid = '&processid';

select sql_fulltext
from v$sqlarea
where sql_id = '&v_sql_id';      

select * 
from table(dbms_xplan.display_cursor('&v_sql_id', &v_sql_child_number));
