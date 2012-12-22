/**********************************************************************
 * File:	latches.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	20-Sep-99
 *
 * Description:
 *	Query to find the latches which are being waited on the longest.
 *	GETS is the total number of times the latch is acquired.
 *	IMMEDIATE_GETS is the number of times the latch was acquired
 *	without waiting at all.  SPIN_GETS is the number of times that
 *	the latch was not acquired immediately, but was acquired after
 *	1-6 "spins" or "non-pre-emptive waits".  SLEEPS is the number
 *	of times the latch was neither acquired immediately nor acquired
 *	by non-pre-emptive waits, but instead required one or more
 *	"pre-emptive waits" (i.e. the process went to "sleep",
 *	relinquishing the CPU).  The latches with the most SLEEPS are
 *	the site of the most contention...
 *
 *	Mind you, none of this is a problem unless the wait-event
 *	"latch free" is one of the top five or ten problems in the
 *	V$SYSTEM_EVENT view, when queried and sorted according to
 *	the column TIME_WAITED.  If "latch free" is not a problem
 *	overall, then it makes little sense to worry about the results
 *	of this report...
 *
 * Modifications:
 **********************************************************************/
set echo off feedback off timing off trimspool on pages 1000 lines 500

col name format a25 heading "Latch Name" truncate
col gets format 9,999,999,990 heading "Total Gets"
col immediate_gets format 9,999,999,990 heading "Immediate|Gets"
col spin_gets format 999,990 heading "Spin Gets"
col sleeps format 9,999,990 heading "Sleeps"
col instance new_value V_INSTANCE noprint

select  lower(replace(t.instance,chr(0),'')) instance
from    v$thread        t,
        v$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));

select	name,
	gets,
	immediate_gets,
	spin_gets,
	sleeps
from	v$latch
where	gets > 0
order by sleeps desc

spool latches_&&V_INSTANCE
/
spool off
