column dcol new_value mydate noprint

select to_char(sysdate,'YYYYMMDD') dcol from dual;

set pagesize 9999
set trimspool on
set feedback off
set linesize 100

column owner format A15
column segment_name format A20
column segment_type format A20
column extends format 9G999
column max_extents format 9G999

spool &mydate._extents_report.txt

select
    owner,
    segment_name,
    segment_type,
    extents,
    max_extents
from
    dba_segments
where
    max_extents - extents <= 3
order by
    owner,
    segment_name,
    segment_type;

spool off


column dummy noprint
column  pct_used format 999D9       heading "%|Used"
column  name    format a16      heading "Tablespace Name"
column  Kbytes   format 999G999G999    heading "KBytes"
column  used    format 999G999G999   heading "Used"
column  free    format 999G999G999  heading "Free"
column  largest    format 999G999G999  heading "Largest"
break   on report
compute sum of kbytes on report
compute sum of free on report
compute sum of used on report

spool &mydate._space_report.txt

select nvl(b.tablespace_name,
             nvl(a.tablespace_name,'UNKOWN')) name,
       kbytes_alloc kbytes,
       kbytes_alloc-nvl(kbytes_free,0) used,
       nvl(kbytes_free,0) free,
       ((kbytes_alloc-nvl(kbytes_free,0))/
                          kbytes_alloc)*100 pct_used,
       nvl(largest,0) largest
from ( select sum(bytes)/1024 Kbytes_free,
              max(bytes)/1024 largest,
              tablespace_name
       from  sys.dba_free_space
       group by tablespace_name ) a,
     ( select sum(bytes)/1024 Kbytes_alloc,
              tablespace_name
       from sys.dba_data_files
       group by tablespace_name )b
where a.tablespace_name (+) = b.tablespace_name
order by 1
/

spool off
exit;
