set termout off
set heading off
set feedback off
set linesize 50
spool xtmpx.sql
select '@getcode ' || object_name
from user_objects
where object_type in ( 'PROCEDURE', 'FUNCTION', 'PACKAGE' )
/
spool off
spool getallcode_INSTALL
select '@' || object_name
from user_objects
where object_type in ( 'PROCEDURE', 'FUNCTION', 'PACKAGE' )
/
spool off
set heading on
set feedback on
set linesize 130
set termout on
@xtmpx.sql
