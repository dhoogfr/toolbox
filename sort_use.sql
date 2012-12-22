/**********************************************************************
 * File:	sort_use.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	20-May-99
 *
 * Description:
 *	Query the V$SORT_USAGE view to determine what sessions (and
 *	what SQL statements) are using sorting resources...
 *
 * Modifications:
 *********************************************************************/
break on report
compute sum of mb on report
compute sum of pct on report

col sid format a10 heading "Session ID"
col username format a10 heading "User Name"
col sql_text format a8 heading "SQL"
col tablespace format a10 heading "Temporary|TS Name"
col mb format 999,999,990 heading "Mbytes|Used"
col pct format 990.00 heading "% Avail|TS Spc"

select	s.sid || ',' || s.serial# sid,
	s.username,
	u.tablespace,
	substr(a.sql_text, 1, (instr(a.sql_text, ' ')-1)) sql_text,
	u.blocks/128 mb,
	((u.blocks/128)/(sum(f.blocks)/128))*100 pct
from	v$sort_usage	u,
	v$session	s,
	v$sqlarea	a,
	dba_data_files	f
where	s.saddr = u.session_addr
and	a.address (+) = s.sql_address
and	a.hash_value (+) = s.sql_hash_value
and	f.tablespace_name = u.tablespace
group by
	s.sid || ',' || s.serial#,
	s.username,
	substr(a.sql_text, 1, (instr(a.sql_text, ' ')-1)),
	u.tablespace,
	u.blocks/128

spool sort_use
/
spool off
