/**********************************************************************
 * File:	extmap.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	26-Aug-99
 *
 * Description:
 *	Simple report against the DBA_EXTENTS view for Oracle8
 *	databases.  This report is intended to be run periodically
 *	(i.e. daily or several times daily), each time overwriting
 *	itself.
 *
 *	The report's main purpose is to provide a mapping of objects
 *	and their extents by the datafiles in the database, so that
 *	in the event of the need for an "object point-in-time"
 *	recovery, only the necessary datafiles need to be restored
 *	and recovered in the CLONE database.
 *
 *	This report is one of those you hope you never have to use,
 *	but if you need it, you'll kiss me full on the lips for giving
 *	it to you!
 *
 * Modifications:
 *********************************************************************/
whenever oserror exit failure
whenever sqlerror exit failure

set pagesize 1000 linesize 500 trimspool on echo off feedback off timing off -
	pause off verify off recsep off

break on owner

col instance new_value V_INSTANCE noprint

select  lower(replace(t.instance,chr(0),'')) instance
from    v$thread        t,
        v$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));

col seg format a30 heading "Owner.Name" word_wrap
col location format a43 heading "TableSpace:FileName" word_wrap
col exts format 990 heading "#Exts"

select	e.owner || '.' || e.segment_name ||
		decode(e.partition_name,'','',' ('||e.partition_name||')') seg,
	e.tablespace_name || ':' || f.file_name location,
	count(distinct e.block_id) exts
from	sys.dba_extents		e,
	sys.dba_data_files	f
where	e.segment_type in
	('CLUSTER','LOBINDEX','LOBSEGMENT','TABLE','TABLE PARTITION')
and	f.file_id = e.relative_fno
group by e.owner || '.' || e.segment_name ||
		decode(e.partition_name,'','',' ('||e.partition_name||')'),
	 e.tablespace_name || ':' || f.file_name
order by 1, 2

set termout off
spool extmap_&&V_INSTANCE
/
exit success
