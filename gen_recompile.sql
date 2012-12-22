/**********************************************************************
 * File:        gen_recompile.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (SageLogix, Inc.)
 * Date:        10-Oct-98
 *
 * Description:
 *      SQL*Plus script to use the technique of "SQL-generating-SQL"
 *	to generate another SQL*Plus script to recompile any invalid
 *	objects.  Then, the generated script is run...w
 *
 * Modifications:
 *********************************************************************/
whenever oserror exit failure
whenever sqlerror exit failure

set echo off feedb off time off timi off pages 0 lines 80 pau off verify off

select	'alter ' || decode(object_type,
			   'PACKAGE BODY', 'PACKAGE',
			   'TYPE BODY', 'TYPE',
			   object_type) ||
	' "' || owner || '"."' || object_name || '" compile' ||
	decode(object_type,
		'PACKAGE BODY', ' body;',
		'TYPE BODY', ' body;',
		';') cmd
from	all_objects
where	status = 'INVALID'

spool run_recompile.sql
/
spool off

set echo on feedback on timing on

spool run_recompile
start run_recompile
spool off

REM host /bin/rm -f run_recompile.*

exit success