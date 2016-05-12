set linesize 150
set pages 9999

column sid format 9999
column serial# format 99999
column name format a20
column username format a15
column logon format a20
column idle format a10
column value format 9G999G999G999
column program format a50

select sid, serial#, username, program, name, value, logon, idle
from ( select sess.sid, sess.serial#, sess.username, program, statn.name, sesst.value,
              to_char(sess.logon_time, 'DD/MM/YYYY HH24:MI:SS') logon,
              floor(sess.last_call_et/3600)||':'|| floor(mod(sess.last_call_et,3600)/60)||':'|| mod(mod(sess.last_call_et,3600),60) idle,
              row_number() over
                ( partition by statn.name
                  order by sesst.value desc
                 ) rn
       from v$session sess, v$sesstat sesst, v$statname statn
       where sess.sid = sesst.sid
             and sesst.statistic# = statn.statistic#
             and statn.name in
                ('redo blocks written', 'redo size', 'redo wastage')
             and sesst.value > 0
     )
where rn <= 5
order by name, value desc;
