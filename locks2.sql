column os_user_name format a20
column process format a10
column oracle_username format a30
column owner format a30
column object_name format a30
column sid format 99999
column type format a30
column lmode format a15
column request format a15
column block format a15
set linesize 120

select os_user_name, lo.process, oracle_username, l.sid, s.sid, s.serial#, s.PADDR,
       decode( l.TYPE, 
               'MR', 'Media Recovery',
               'RT', 'Redo Thread',
               'UN', 'User Name',
               'TX', 'Transaction',
               'TM', 'DML',
               'UL', 'PL/SQL User Lock',
               'DX', 'Distributed Xaction',
               'CF', 'Control File',
               'IS', 'Instance State',
               'FS', 'File Set',
               'IR', 'Instance Recovery',
               'ST', 'Disk Space Transaction',
               'TS', 'Temp Segment',
               'IV', 'Library Cache Invalidation',
               'LS', 'Log Start or Switch',
               'RW', 'Row Wait',
               'SQ', 'Sequence Number',
               'TE', 'Extend Table',
               'TT', 'Temp Table', 
               l.type
             ) type,
       decode( l.LMODE,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive', 
               l.lmode
             ) lmode,
       decode( l.REQUEST,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive', 
               l.request
             ) request,
       decode( l.BLOCK,
               0, 'Not Blocking',
               1, 'Blocking',
               2, 'Global', 
               l.block
             ) block,
       owner, object_name
from sys.v_$locked_object lo, dba_objects do, sys.v_$lock l, v$session s
where lo.OBJECT_ID = do.OBJECT_ID
      and l.SID = lo.SESSION_ID
      and l.sid = s.sid;