set linesize 130

column column_name format a30
column owner format a20
column mb format 9G999G999D99
column tablespace_name format a30

break on owner skip 1 on table_name

select lob.owner, lob.table_name, lob.column_name, seg.tablespace_name, seg.bytes/1024/1024 mb
from dba_segments seg, dba_lobs lob
where lob.owner = seg.owner
      and lob.segment_name = seg.segment_name
      and lob.owner not in
        ( 'CTXSYS', 'DBSNMP', 'DMSYS', 'EXFSYS', 'OUTLN', 'SYS', 'SYSTEM', 'SYSMAN',
          'TSMSYS', 'WKSYS', 'WK_TEST', 'WMSYS', 'WK_TEST', 'XDB', 'ANONYMOUS', 'WKPROXY', 'MGMT_VIEW',
          'DIP'
        )
order by lob.owner, lob.table_name, lob.column_name;

clear breaks
