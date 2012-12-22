column sz_mb format 9G999G999D99
column name format a30

set linesize 140
set pages 9999

select to_char(time, 'DD/MM/YYYY HH24:MI:SS') time, scn,name, database_incarnation# db_inc#, 
       guarantee_flashback_database gfd, storage_size/1024/1024 sz_mb
from v$restore_point rstp
order by scn desc;
