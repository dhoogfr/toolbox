/**********************************************************************
 * File:	filestat.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	20-Sep-99
 *
 * Description:
 *	Report against the V$FILESTAT table to detect the tablespace
 *	with the greatest I/O load, according the volume of reads and
 *	writes, weighted against the average I/O time...
 *
 *	Because this script depends on the timing information in the
 *	V$FILESTAT view, please be sure to have the configuration
 *	TIMED_STATISTICS set to TRUE to get the full value of this
 *	report...
 *
 * Modifications:
 *********************************************************************/
col ts_name format a25 truncate
col sort0 noprint
col io format a43 heading "Reads Writes|Rqsts,Blks,#Bks/Rqst"
col rds format a25 heading "Reads|Rds/Bks(#bks/Rd)"
col wrts format a25 heading "Writes|Wrts/Bks(#bks/Wrt)"
col avgiotim format 999990.0

set echo on feedback off timing off trimspool on pages 1000 lines 500

col instance new_value V_INSTANCE noprint
select  lower(replace(t.instance,chr(0),'')) instance
from    v$thread        t,
        v$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));
spool filestat_&&V_INSTANCE

select	avg(nvl(s.avgiotim,0)) * sum(nvl(s.phyrds,0) + nvl(s.phywrts,0)) sort0,
	f.tablespace_name ts_name,
	ltrim(to_char(sum(s.phyrds))) || ',' ||
		ltrim(to_char(sum(s.phyblkrd))) || ',' ||
		ltrim(to_char(sum(s.phyblkrd)/
			decode(sum(s.phyrds),0,1,sum(s.phyrds)),'990.0'))
		|| ' | ' ||
	ltrim(to_char(sum(s.phywrts))) || ',' ||
		ltrim(to_char(sum(s.phyblkwrt))) || ',' ||
		ltrim(to_char(sum(s.phyblkwrt)/
			decode(sum(s.phywrts),0,1,sum(s.phywrts)),'990.0')) io,
	avg(s.avgiotim) avgiotim
from	v$filestat	s,
	dba_data_files	f
where	f.file_id = s.file#
group by
	f.tablespace_name
order by sort0 desc, ts_name
/

spool off
