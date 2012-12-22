/**********************************************************************
 * File:        temp_enqwaits.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        05Feb01
 *
 * Description:
 *      Script to execute the ENQWAITS stored procedure as a "PL/SQL
 *	anonymous block", so that the procedure can be run under SYS
 *	without creating any permanent objects (like a stored procedure)...
 *
 * Modifications:
 *	TGorman	05Feb01	written
 *	TGorman	21May01	adapted from "run_enqwaits.sql" and "enqwaits.sql"
 *
 *********************************************************************/
set serveroutput on size 1000000
set echo off feedback off trimspool on verify off
col instance new_value V_INSTANCE noprint
select  lower(replace(t.instance,chr(0),'')) instance
from    sys.v_$thread        t,
        sys.v_$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));

REM
REM If your installation is running Oracle Apps R11+, then leave the following
REM two substitution variables containing blank values.
REM
REM If your database is not running Oracle Apps, then assign the string "/*"
REM (i.e. start comment) to the substitution variable START_ORACLE_APPS_CODE and
REM the string "*/" (i.e. end comment) to the substitution variables
REM END_ORACLE_APPS_CODE.
REM
define START_ORACLE_APPS_CODE="--"
define END_ORACLE_APPS_CODE="--"

spool enqwaits_&&V_INSTANCE

declare
	--
	b_GetRelatedSessions	boolean := FALSE;
	--
	cursor get_sqltext(in_address in raw)
	is
	select	SQL_TEXT
	from	SYS.V_$SQLTEXT
	where	ADDRESS = in_address
	order by PIECE;
	--
	cursor get_waiters
	is
	select	SID,
		TYPE,
		DECODE(TYPE,
			'BL','Buffer hash table',
			'CF','Control File Transaction',
			'CI','Cross Instance Call',
			'CS','Control File Schema',
			'CU','Bind Enqueue',
			'DF','Data File',
			'DL','Direct-loader index-creation',
			'DM','Mount/startup db primary/secondary instance',
			'DR','Distributed Recovery Process',
			'DX','Distributed Transaction Entry',
			'FI','SGA Open-File Information',
			'FS','File Set',
			'IN','Instance Number',
			'IR','Instance Recovery Serialization',
			'IS','Instance State',
			'IV','Library Cache InValidation',
			'JQ','Job Queue',
			'KK','Redo Log "Kick"',
			'LS','Log Start/Log Switch',
			'MB','Master Buffer hash table',
			'MM','Mount Definition',
			'MR','Media Recovery',
			'PF','Password File',
			'PI','Parallel Slaves',
			'PR','Process Startup',
			'PS','Parallel Slaves Synchronization',
			'RE','USE_ROW_ENQUEUE Enforcement',
			'RT','Redo Thread',
			'RW','Row Wait',
			'SC','System Commit Number',
			'SH','System Commit Number HWM',
			'SM','SMON',
			'SQ','Sequence Number',
			'SR','Synchronized Replication',
			'SS','Sort Segment',
			'ST','Space Transaction',
			'SV','Sequence Number Value',
			'TA','Transaction Recovery',
			'TD','DDL enqueue',
			'TE','Extend-segment enqueue',
			'TM','DML enqueue',
			'TS','Temporary Segment',
			'TT','Temporary Table',
			'TX','Transaction',
			'UL','User-defined Lock',
			'UN','User Name',
			'US','Undo Segment Serialization',
			'WL','Being-written redo log instance',
			'WS','Write-atomic-log-switch global enqueue',
			'XA','Instance Attribute',
			'XI','Instance Registration',
			decode(substr(TYPE,1,1),
			    'L','Library Cache ('||substr(TYPE,2,1)||')',
			    'N','Library Cache Pin ('||substr(TYPE,2,1)||')',
			    'Q','Row Cache ('||substr(TYPE,2,1)||')',
				'????')) LOCK_TYPE,
		REQUEST,
		DECODE(REQUEST,
			0, '',
			1, 'Null',
			2, 'Sub-Share',
			3, 'Sub-Exclusive',
			4, 'Share',
			5, 'Share/Sub-Excl',
			6, 'Exclusive',
				'<Unknown>') MODE_REQUESTED,
		ID1,
		ID2
	from	SYS.V_$LOCK
	where	REQUEST > 0
	and	LMODE = 0;
	--
	cursor get_blockers(in_type in varchar2,
			    in_id1 in number,
			    in_id2 in number,
			    in_sid in number)
	is
	select	SID,
		TYPE,
		DECODE(TYPE,
			'BL','Buffer hash table',
			'CF','Control File Transaction',
			'CI','Cross Instance Call',
			'CS','Control File Schema',
			'CU','Bind Enqueue',
			'DF','Data File',
			'DL','Direct-loader index-creation',
			'DM','Mount/startup db primary/secondary instance',
			'DR','Distributed Recovery Process',
			'DX','Distributed Transaction Entry',
			'FI','SGA Open-File Information',
			'FS','File Set',
			'IN','Instance Number',
			'IR','Instance Recovery Serialization',
			'IS','Instance State',
			'IV','Library Cache InValidation',
			'JQ','Job Queue',
			'KK','Redo Log "Kick"',
			'LS','Log Start/Log Switch',
			'MB','Master Buffer hash table',
			'MM','Mount Definition',
			'MR','Media Recovery',
			'PF','Password File',
			'PI','Parallel Slaves',
			'PR','Process Startup',
			'PS','Parallel Slaves Synchronization',
			'RE','USE_ROW_ENQUEUE Enforcement',
			'RT','Redo Thread',
			'RW','Row Wait',
			'SC','System Commit Number',
			'SH','System Commit Number HWM',
			'SM','SMON',
			'SQ','Sequence Number',
			'SR','Synchronized Replication',
			'SS','Sort Segment',
			'ST','Space Transaction',
			'SV','Sequence Number Value',
			'TA','Transaction Recovery',
			'TD','DDL enqueue',
			'TE','Extend-segment enqueue',
			'TM','DML enqueue',
			'TS','Temporary Segment',
			'TT','Temporary Table',
			'TX','Transaction',
			'UL','User-defined Lock',
			'UN','User Name',
			'US','Undo Segment Serialization',
			'WL','Being-written redo log instance',
			'WS','Write-atomic-log-switch global enqueue',
			'XA','Instance Attribute',
			'XI','Instance Registration',
			decode(substr(TYPE,1,1),
			    'L','Library Cache ('||substr(TYPE,2,1)||')',
			    'N','Library Cache Pin ('||substr(TYPE,2,1)||')',
			    'Q','Row Cache ('||substr(TYPE,2,1)||')',
				'????')) LOCK_TYPE,
		LMODE,
		DECODE(LMODE,
			0, '--Waiting--',
			1, 'Null',
			2, 'Sub-Share',
			3, 'Sub-Exclusive',
			4, 'Share',
			5, 'Share/Sub-Excl',
			6, 'Exclusive',
				'<Unknown>') MODE_HELD,
		ID1,
		ID2
	from	SYS.V_$LOCK
	where	TYPE = in_type
	and	ID1 = in_id1
	and	ID2 = in_id2
	and	SID <> in_sid
	and	LMODE > 0
	and	REQUEST = 0;
	--
	cursor get_related_sessions(in_sid in number)
	is
	select	S.SID,
		S.SERIAL# SNBR,
		S.LOGON_TIME,
		S.USERNAME,
		S.SQL_ADDRESS,
		S.STATUS,
		S.OSUSER,
		P.SPID,
		T.XIDUSN || '.' || T.XIDSLOT || '.' || T.XIDSQN TXN_ID,
		T.STATUS TXN_STATUS,
		T.START_TIME TXN_START_TIME,
		T.USED_UBLK,
		T.USED_UREC
	from	SYS.V_$SESSION		S1,
		SYS.V_$SESSION		S,
		SYS.V_$PROCESS		P,
		SYS.V_$TRANSACTION	T
	where	S1.SID = in_sid
	and	S.PADDR = S1.PADDR
	and	P.ADDR = S1.PADDR
	and	T.ADDR (+) = S1.TADDR
	order by decode(S.SID, in_sid, 0, S.SID);
	--
	cursor get_dml_locks(in_sid in number)
	is
	select	o.OWNER,
		o.OBJECT_TYPE type,
		o.OBJECT_NAME name,
		decode(l.LMODE,
			0, 'REQUESTED=' ||
				DECODE(l.REQUEST,
					0, '--Waiting--',
					1, 'Null',
					2, 'Sub-Share',
					3, 'Sub-Exclusive',
					4, 'Share',
					5, 'Share/Sub-Excl',
					6, 'Exclusive',
						'<Unknown>'),
			   'HELD=' ||
				DECODE(l.LMODE,
					0, '--Waiting--',
					1, 'Null',
					2, 'Sub-Share',
					3, 'Sub-Exclusive',
					4, 'Share',
					5, 'Share/Sub-Excl',
					6, 'Exclusive',
						'<Unknown>')) lmode
	from	sys.V_$LOCK	l,
		sys.DBA_OBJECTS	o
	where	l.sid = in_sid
	and	l.type = 'TM'
	and	o.object_id = l.id1;
	--
	v_waiter_username	varchar2(30);
	v_blocker_username	varchar2(30);
	v_errcontext		varchar2(80);
	v_errmsg		varchar2(300);
	--
begin
--
v_errcontext := 'open/fetch get_waiters';
for w in get_waiters loop
    --
    dbms_output.put_line('.');
    v_errcontext := 'open/fetch get_related_sessions (waiters)';
    for rw in get_related_sessions(w.sid) loop
        --
	if w.sid = rw.sid then
	    --
	    v_waiter_username := rw.username;
	    --
&&START_ORACLE_APPS_CODE
	    v_errcontext := 'query waiters OraApps user info';
	    begin
		select	u.user_name
		into	v_waiter_username
		from	apps.fnd_logins	l,
			apps.fnd_user	u
		where	l.spid = rw.spid
		and	l.login_name = rw.osuser
		and	l.end_time is null
		and	l.start_time =
			(select max(ll.start_time)
			 from   apps.fnd_logins ll
			 where  ll.spid = l.spid
			 and    ll.end_time is null)
		and	u.user_id = l.user_id;
	    exception
		when no_data_found then
		    v_waiter_username := '';
		when too_many_rows then
		    null;
	    end;
&&END_ORACLE_APPS_CODE
	    --
	    v_errcontext := 'PUT_LINE waiters session/lock info';
	    dbms_output.put_line(substr('Waiter: SID=' || rw.sid ||
				' (' || rw.status || '), Logged on at ' ||
				to_char(rw.logon_time,'DD-MON HH24:MI'),1,78));
	    dbms_output.put_line('....... REQUESTED LOCK|MODE=' ||
				w.type || ' (' || w.lock_type ||
				') | ' || w.mode_requested ||
				' (' || w.id1 || ',' || w.id2 || ')');
	    dbms_output.put_line('....... AppsUser=' || v_waiter_username);
	    dbms_output.put_line('....... OS PID=' || rw.spid);
	    --
	else
	    --
	    if b_GetRelatedSessions = FALSE then
		--
		exit; -- ...exit from "get_related_sessions" cursor loop
		--
	    end if;
	    --
	    v_errcontext := 'PUT_LINE related waiters session info';
	    dbms_output.put_line(substr('... Related waiting SID=' ||
				rw.sid || ' (' || rw.status ||
				'), Logged on at ' ||
				to_char(rw.logon_time,'DD-MON HH24:MI'),1,78));
	    --
	end if;
	--
	dbms_output.put_line('.... TXN ID=' || rw.txn_id ||
		' (' || rw.txn_status || ') started=' ||
		rw.txn_start_time || ' undo=' || rw.used_ublk || 'b/' ||
		rw.used_urec || 'r');
	--
	v_errcontext := 'open/fetch get_dml_locks (waiters)';
	for d in get_dml_locks(rw.sid) loop
	    --
	    dbms_output.put_line(substr('....... DML Lock: ' ||
		d.owner || '.' || d.name || ' (' || d.type || ') - LOCK ' ||
		d.lmode,1,78));
	    --
	    v_errcontext := 'fetch/close get_dml_locks (waiters)';
	    --
	end loop; /* end of "get_dml_locks (waiters)" cursor loop */
	--
	dbms_output.put_line('.... SQL Statement currently executing:');
	v_errcontext := 'open/fetch waiters get_sqltext';
	for t in get_sqltext(rw.sql_address) loop
	    --
	    dbms_output.put_line('....... ' || t.sql_text);
	    --
	    v_errcontext := 'fetch/close waiters get_sqltext';
	    --
	end loop; /* end of "get_sqltext" cursor loop */
	--
	v_errcontext := 'fetch/close get_related_sessions (waiters)';
	--
    end loop; /* end of "get_related_sessions (waiters)" cursor loop */
    --
    v_errcontext := 'open/fetch get_blockers';
    for b in get_blockers(w.type, w.id1, w.id2, w.sid) loop
	--
	v_errcontext := 'open/fetch get_related_sessions (blockers)';
	for rb in get_related_sessions(b.sid) loop
	    --
            if b.sid = rb.sid then
		--
		v_blocker_username := rb.username;
		--
		&&START_ORACLE_APPS_CODE
	        v_errcontext := 'query blockers OraApps user info';
	        begin
		    select	u.user_name
		    into	v_blocker_username
		    from	apps.fnd_logins	l,
				apps.fnd_user	u
		    where	l.spid = rb.spid
		    and		l.login_name = rb.osuser
		    and		l.end_time is null
		    and		l.start_time =
				(select max(ll.start_time)
				 from   apps.fnd_logins ll
				 where  ll.spid = l.spid
				 and    ll.end_time is null)
		    and		u.user_id = l.user_id;
	        exception
		    when no_data_found then
			v_blocker_username := '';
		    when too_many_rows then
			null;
	        end;
		&&END_ORACLE_APPS_CODE
	        --
	        v_errcontext := 'PUT_LINE blockers session/lock info';
	        dbms_output.put_line(substr('==>BLOCKER: SID=' || rb.sid ||
				',' || rb.snbr ||
				' (' || rb.status || '), Logged on at ' ||
				to_char(rb.logon_time,'DD-MON HH24:MI'),1,78));
	        dbms_output.put_line('........... HELD LOCK|MODE=' ||
				b.type || ' (' || b.lock_type ||
				') | ' || b.mode_held);
	        dbms_output.put_line('........... AppsUser=' ||
				v_blocker_username);
		dbms_output.put_line('........... OS PID=' || rb.spid);
		--
	    else
		--
		if b_GetRelatedSessions = FALSE then
		    --
		    exit; -- ...exit from "get_related_sessions" cursor loop
		    --
		end if;
		--
		v_errcontext := 'PUT_LINE related blockers session info';
		dbms_output.put_line(substr('...... Related BLOCKER: SID='
				|| rb.sid || ' (' || rb.status ||
				'), Logged on at ' ||
				to_char(rb.logon_time,'DD-MON HH24:MI'),1,78));
		--
	    end if;
	    --
	    dbms_output.put_line('....... TXN ID=' || rb.txn_id ||
		' (' || rb.txn_status || ') started=' ||
		rb.txn_start_time || ' undo=' || rb.used_ublk || 'b/' ||
		rb.used_urec || 'r');
	    --
	    v_errcontext := 'open/fetch get_dml_locks (blockers)';
	    for d in get_dml_locks(rb.sid) loop
		--
		dbms_output.put_line(substr('........... DML Lock: ' ||
		    d.owner || '.' || d.name || ' (' || d.type || ') - LOCK ' ||
		    d.lmode,1,78));
		--
		v_errcontext := 'fetch/close get_dml_locks (blockers)';
		--
	    end loop; /* end of "get_dml_locks (blockers)" cursor loop */
	    --
	dbms_output.put_line('....... SQL currently executing (not necessarily the blocking SQL):');
	    v_errcontext := 'open/fetch get_sqltext (blockers)';
	    for t in get_sqltext(rb.sql_address) loop
		--
		dbms_output.put_line('........... ' || t.sql_text);
		--
		v_errcontext := 'fetch/close get_sqltext (blockers)';
		--
	    end loop; /* end of "get_sqltext (blockers)" cursor loop */
	    --
	    v_errcontext := 'fetch/close get_related_sessions (blockers)';
	    --
	end loop; /* end of "get_related_sessions (blockers)" cursor loop */
	--
	v_errcontext := 'fetch/close get_blockers';
	--
    end loop; /* end of "get_blockers" cursor loop */
    --
    v_errcontext := 'fetch/close get_waiters';
    --
end loop; /* end of "get_waiters" cursor loop */
--
exception
	when others then
		v_errmsg := substr(sqlerrm, 1, 300);
		raise_application_error(-20001, v_errcontext||': '||v_errmsg);
end;
/
spool off
ed enqwaits_&&V_INSTANCE..lst
