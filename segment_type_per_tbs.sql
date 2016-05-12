set linesize 120
set pages 9999

column counted format 99G999
column mb format 9G999G999D99

compute sum of mb on owner report
compute sum of counted on owner report

break on owner skip 1 on tablespace_name on report

select owner, tablespace_name, segment_type, sum(bytes)/1024/1024 MB, count(*) counted
from dba_segments
where owner not in ( 'DBSNMP', 'DIP', 'MGMT_VIEW', 'ORACLE_OCM', 'OUTLN', 'SYS', 
                     'SYSMAN', 'SYSTEM', 'TSMSYS', 'WMSYS'
                   )
group by owner, tablespace_name, segment_type
order by owner, tablespace_name, segment_type;

clear breaks
