column xdb new_value xxdb noprint
select to_char(sysdate,'YYYYMMDDhh24miss')||'_'||name xdb from v$database;

set pagesize 9999
set linesize 180
set feedback on
set trimspool on
set echo off

spool overview_&&xxdb..txt

PROMPT instance_name:
PROMPT
select instance_name from v$instance;

PROMPT date report:
PROMPT
select to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS') from dual;
PROMPT

PROMPT oracle version:
PROMPT
select banner from v$version;
PROMPT

PROMPT
PROMPT tablespace used and free space
PROMPT
column dummy noprint
column  pct_used format 999.9       heading "%|Used"
column  name    format a16      heading "Tablespace Name"
column  Kbytes   format 999,999,999    heading "KBytes"
column  used    format 999,999,999   heading "Used"
column  free    format 999,999,999  heading "Free"
column  largest    format 999,999,999  heading "Largest"
column  max_size format 999,999,999 heading "MaxPoss|Kbytes"
column  pct_max_used format 999.9       heading "%|Max|Used"
break   on report
compute sum of kbytes on report
compute sum of free on report
compute sum of used on report

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
order by 1;


PROMPT
PROMPT segment within 20 extents of their max extents
PROMPT
select tablespace_name, owner, segment_type, segment_name, extents,
       max_extents - extents delta
from dba_segments
where max_extents <= extents + 20
order by tablespace_name, owner, segment_type;

PROMPT
PROMPT segments that can't allocate their next extent
PROMPT
select A.tablespace_name, max_bytes_free/1024, max_next/1024, (max_next - max_bytes_free)/1024 delta
from ( select tablespace_name, max(bytes) max_bytes_free
       from dba_free_space
       group by tablespace_name
     ) A,
     ( select tablespace_name, max(next_extent) max_next
       from dba_segments
       group by tablespace_name
     ) B
where A.tablespace_name = B.tablespace_name
      and B.max_next >= A.max_bytes_free
order by 1;

PROMPT
PROMPT non system objects in system tablespace
PROMPT
select owner, count(*) counted, sum(bytes)/1024 kb_used
from dba_segments
where tablespace_name = 'SYSTEM'
      and owner not in ('SYSTEM', 'SYS')
group by owner
order by owner;

PROMPT
PROMPT permanent objects in temporary tablespace
PROMPT
select tablespace_name, segment_type, count(*) counted
from dba_segments
where tablespace_name in
          ( select tablespace_name
            from dba_tablespaces
            where contents = 'TEMPORARY'
          )
      and segment_type != 'TEMPORARY'
group by tablespace_name, segment_type
order by tablespace_name, segment_type;

PROMPT
PROMPT archived redo logs per day (max last 10 days)
PROMPT
column gen_archived_size format 9G999G999D99

select to_char(completion_time, 'DD/MM/YYYY') day, count(*) switches,
              sum(blocks * block_size)/1024/1024 gen_archived_size
from v$archived_log
where first_time >= sysdate - 10
group by trunc(completion_time), to_char(completion_time, 'DD/MM/YYYY')
order by trunc(completion_time);

PROMPT
PROMPT average per day
PROMPT
select to_char(min(dag), 'DD/MM/YYYY HH24:MI:SS') start_day,
       to_char(max(dag) + 1 - 1/(24*60*60), 'DD/MM/YYYY HH24:MI:SS') end_day,
       (max(dag) - min(dag) + 1) days_between,
           to_char(avg(gen_archived_size),'9G999G999D99') avg_archived_per_day
from ( select trunc(completion_time) dag,
              sum(blocks * block_size)/1024/1024 gen_archived_size
       from v$archived_log
       where months_between(trunc(sysdate), trunc(completion_time)) <= 1
             and completion_time < trunc(sysdate)
       group by trunc(completion_time)
     );

PROMPT
PROMPT invalid objects
PROMPT
select owner, object_type, count(*) counted
from dba_objects
where status = 'INVALID'
group by owner, object_type
order by 1,2;

PROMPT
PROMPT overview db users:
PROMPT
column temporary_tablespace format a30 heading T_TBS
column default_tablespace format a30 heading D_TBS
column account_status format a15 word_wrapped heading STATUS
colum username format a30
column created format a12
column dba format a3
column ops$ format a4
select A.username, default_tablespace, temporary_tablespace,
       to_char(created, 'DD/MM/YYYY') created,
       decode(password, 'EXTERNAL', 'Y', 'N') as OPS$,
       decode(B.granted_role, 'DBA', 'Y', 'N') as dba,
       account_status
from dba_users A,
     ( select grantee, granted_role
       from dba_role_privs
       where granted_role = 'DBA'
     ) B
where A.username = B.grantee(+)
order by A.created;

spool off
exit