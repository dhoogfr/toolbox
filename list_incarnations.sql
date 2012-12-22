set linesize 120
set pages 999
column incarnation format a15
column fdo format a5

select rpad(' ', level) || incarnation# incarnation, prior_incarnation#, resetlogs_id, resetlogs_change#, 
       to_char(resetlogs_time, 'DD/MM/YYYY HH24:MI:SS') resetlogstime, status, flashback_database_allowed fdo
from v$database_incarnation
connect by prior_incarnation# = prior incarnation#
      start with prior_incarnation# = 0
order siblings by incarnation#, resetlogs_time;