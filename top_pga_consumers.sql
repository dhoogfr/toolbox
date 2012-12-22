set linesize 150
set pagesize 999

column name format a25
column mb format 9G999D99
column sid format 99999
column serial# format 99999
column machine format a20
column username format a15
column program format a25
column logon_time format a10

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
  where rn <= 10
)
select tpga.name, sess.sid, sess.serial#, tpga.value/1024/1024 mb,
       sess.username, sess.machine, sess.program,
       sess.sql_id, sess.logon_time
from toppga tpga, v$session sess
where tpga.sid = sess.sid
order by tpga.name, mb desc;

clear breaks
