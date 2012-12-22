set pagesize 9999
set linesize 150
column member format a75
column type format a10
column status format a10
column arch format a4
column thread# format 99 heading THREAD#
column group# format 99 heading GROUP#

break on type on thread# nodup skip 1 on type nodup on GROUP# nodup

select type, A.thread#, A.group#, B.member, A.bytes/1024/1024 mb,A.status, arch
from ( select group#, thread#, bytes, status, archived arch
       from v$log
       union all
       select group#, thread#, bytes, status, archived arch
       from v$standby_log
     ) A, v$logfile B
where A.group# = B.group#
order by type, A.thread#, A.group#, B.member;

clear breaks
