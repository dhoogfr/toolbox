set heading off
set feedback off
set linesize 1000
set trimspool on
set verify off
set termout off
set embedded on

spool tmp.sql
select '@getaview ' || view_name
from user_views
/
spool off

set termout on
set heading on
set feedback on
set verify on
@tmp
