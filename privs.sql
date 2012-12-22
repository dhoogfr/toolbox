/**********************************************************************
 * File:	privs.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	17Dec01
 *
 * Description:
 *	SQL*Plus script to display complete information about the
 *	privileges and roles granted to a user or role.
 *
 * Modifications:
 *********************************************************************/
set echo off feedback off timing off pagesize 66 verify off trimspool on linesize 100
set recsep off

col sort0 noprint
col priv format a65 word_wrap heading "Granted"
col admin_option heading "Adm|Opt"
col dflt heading "Dflt"

undef user

spool privs_&&user

select	1 sort0,
	granted_role	priv,
	admin_option,
	default_role dflt
from	dba_role_privs
where	grantee = decode('&&user','dbo','dbo',upper('&&user'))
union
select	2 sort0,
	privilege	priv,
	admin_option,
	'' dflt
from	dba_sys_privs
where	grantee = decode('&&user','dbo','dbo',upper('&&user'))
union
select	3 sort0,
	privilege || ' on ' || owner || '.' || table_name || ' (by ' || grantor || ')'	priv,
	grantable admin_option,
	'' dflt
from	dba_tab_privs
where	grantee = decode('&&user','dbo','dbo',upper('&&user'))
union
select	4 sort0,
	'QUOTA: ' ||
	decode(q.max_bytes,
		-1, 'UNLIMITED',
		    ltrim(to_char(q.max_bytes/1048576,'999,999,990.00')) || 'M') ||
		' on ' || q.tablespace_name priv,
	'' admin_option,
	decode(u.default_tablespace, q.tablespace_name, 'YES', 'NO') dflt
from	dba_ts_quotas	q,
	dba_users	u
where	u.username = decode('&&user','dbo','dbo',upper('&&user'))
and	q.username = u.username
order by 1, 2, 3, 4;

spool off
