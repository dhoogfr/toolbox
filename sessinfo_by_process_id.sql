select B.sid, B.serial#, C.spid, B.username, B.program, B.osuser, B.machine, A.value
from v$sesstat A, v$session B, v$process C, v$statname D
where A.sid = B.sid
      and B.paddr = C.addr
      and C.spid = '&processid'
      and A.statistic# = D.statistic#
      and D.name = 'CPU used by this session';