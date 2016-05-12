set linesize 150
set pagesize 999

column name format a25
column mb format 9G999G999D99
column sid format 9999
column machine format a15
column osuser format a10
column username format a15
column program format a25

break on name skip 1

with toppga
as
( select /*+ MATERIALIZE */ sid, name, value
  from ( select sid, name, value,
                row_number() over 
                    ( partition by name 
                      order by value desc
                    ) rn
         from v$statname stname, v$sesstat stat
         where stat.STATISTIC# = stname.STATISTIC#
               and name like 'session pga memory%'    
       )
  where rn <= 3
)
select tpga.name, sess.sid, sess.serial#, tpga.value/1024/1024 mb, 
       sess.username, sess.machine, sess.osuser, sess.program
from toppga tpga, v$session sess
where tpga.sid = sess.sid
order by tpga.name, mb;

clear breaks
