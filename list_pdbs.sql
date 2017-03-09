set pages 50000
set linesize 300

column name format a30
column state format a14
column restricted format a10
column open_time_str format a26
column total_size_gb format 999G999D99

select
  name,
  open_mode,
  restricted,
  to_char(open_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') open_time_str,
  (total_size/1024/1024/1024) total_size_gb
from
  v$containers
order by 
  name
;
