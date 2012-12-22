/**********************************************************************
 * File:	tracetrg.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	01Dec01
 *
 * Description:
 *	SQL*Plus script containing the DDL to create a database-level
 *	AFTER LOGON event trigger to enable SQL Trace for a specific
 *	user account only.  Very useful diagnostic tool...
 *
 * Modifications:
 *********************************************************************/
set echo on feedback on timing on

spool tracetrg

create or replace trigger tracetrg
	after logon
	on database
begin
	dbms_session.set_sql_trace(TRUE);
end;
/
show errors

spool off
