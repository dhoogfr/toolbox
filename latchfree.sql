/********************************************************************
 * File:        latchfree.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        01-Dec-99
 *
 * Description:
 *      Script to display more session-level and SQL-level information
 *	about sessions waiting on a "latch free" wait event.
 *
 * Modification:
 *
 ********************************************************************/
set echo off feedback off timing off pause off
set pages 100 lines 500 trimspool on trimout on space 1 recsep each

col sid format 990
col program format a15 word_wrap
col latch format a10 word_wrap
col process format a8 word_wrap heading "Clnt|PID"
col ospid format 9999990 heading "Srvr|PID"
col sql_text format a30 word_wrap
col instance new_value V_INSTANCE noprint
select	lower(replace(t.instance,chr(0),'')) instance
from	sys.v_$thread        t,
	sys.v_$parameter     p
where	p.name = 'thread'
and	t.thread# = to_number(decode(p.value,'0','1',p.value));

select	w.sid,
	c.name || ' (child #' || c.child# || ')' latch,
	s.program,
	s.machine || ', ' || s.process process,
	p.spid ospid,
	a.sql_text
from	v$session_wait		w,
	v$latch_children	c,
	v$session		s,
	v$process		p,
	v$sqlarea		a
where	w.event = 'latch free'
and	c.addr = w.p1raw
and	s.sid = w.sid
and	p.addr = s.paddr
and	a.address (+) = s.sql_address

spool latchfree_&&V_INSTANCE
/
spool off
