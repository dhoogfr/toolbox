/**********************************************************************
 * File:	locks.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	29-Nov-99
 *
 * Description:
 *	Query the V$LOCK view and decode the following columns:
 *		TYPE
 *		LMODE
 *		REQUEST
 *	Also, summarize by these columns...
 *
 *	Enqueue type-names are a composite of Oracle7, Oracle8, and
 *	Oracle8i documentation.  It is up-to-date as of v8.1.5 and
 *	should be valid going back to v7.3.x...
 *
 * Modifications:
 *********************************************************************/
col type format a40 truncate heading "Lock Type"
col mode_held format a14 truncate heading "Mode Held"
col mode_requested format a14 truncate heading "Mode Requested"
col cnt format 9990 heading "#Sess"
col instance new_value V_INSTANCE noprint

set feedback off echo off timing off pause off verify off

select  lower(replace(t.instance,chr(0),'')) instance
from    v$thread        t,
        v$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));

SELECT    TYPE ||
          DECODE(TYPE,
		 'BL',': Buffer hash table',
		 'CF',': Control File Transaction',
		 'CI',': Cross Instance Call',
		 'CS',': Control File Schema',
		 'CU',': Bind Enqueue',
		 'DF',': Data File',
		 'DL',': Direct-loader index-creation',
		 'DM',': Mount/startup db primary/secondary instance',
		 'DR',': Distributed Recovery Process',
		 'DX',': Distributed Transaction Entry',
		 'FI',': SGA Open-File Information',
		 'FS',': File Set',
		 'IN',': Instance Number',
		 'IR',': Instance Recovery Serialization',
		 'IS',': Instance State',
		 'IV',': Library Cache InValidation',
		 'JQ',': Job Queue',
		 'KK',': Redo Log "Kick"',
		 'LS',': Log Start/Log Switch',
		 'MB',': Master Buffer hash table',
		 'MM',': Mount Definition',
		 'MR',': Media Recovery',
		 'PF',': Password File',
		 'PI',': Parallel Slaves',
		 'PR',': Process Startup',
		 'PS',': Parallel Slaves Synchronization',
		 'RE',': USE_ROW_ENQUEUE Enforcement',
		 'RT',': Redo Thread',
		 'RW',': Row Wait',
		 'SC',': System Commit Number',
		 'SH',': System Commit Number HWM',
		 'SM',': SMON',
		 'SQ',': Sequence Number',
		 'SR',': Synchronized Replication',
		 'SS',': Sort Segment',
		 'ST',': Space Transaction',
		 'SV',': Sequence Number Value',
		 'TA',': Transaction Recovery',
		 'TD',': DDL enqueue',
		 'TE',': Extend-segment enqueue',
		 'TM',': DML enqueue',
		 'TS',': Temporary Segment',
		 'TT',': Temporary Table',
		 'TX',': Transaction',
		 'UL',': User-defined Lock',
		 'UN',': User Name',
		 'US',': Undo Segment Serialization',
		 'WL',': Being-written redo log instance',
		 'WS',': Write-atomic-log-switch global enqueue',
		 'XA',': Instance Attribute',
		 'XI',': Instance Registration',
		 decode(substr(type,1,1),
			'L', ': Library Cache ('||substr(type,2,1)||')',
			'N', ': Library Cache Pin ('||substr(type,2,1)||')',
			'Q', ': Row Cache ('||substr(type,2,1)||')',
			     ': ????')) type,
	  DECODE(LMODE,
                 0, '--Waiting--',
                 1, 'Null',
                 2, 'Sub-Share',
                 3, 'Sub-Exclusive',
                 4, 'Share',
                 5, 'Share/Sub-Excl',
                 6, 'Exclusive',
		         '<Unknown>') mode_held,
          DECODE(REQUEST,
                 0, '',
                 1, 'Null',
                 2, 'Sub-Share',
                 3, 'Sub-Exclusive',
                 4, 'Share',
                 5, 'Share/Sub-Excl',
                 6, 'Exclusive',
		         '<Unknown>') mode_requested,
          COUNT(*) cnt
FROM      GV$LOCK
WHERE     TYPE NOT IN ('MR','RT')
GROUP BY  TYPE ||
          DECODE(TYPE,
		 'BL',': Buffer hash table',
		 'CF',': Control File Transaction',
		 'CI',': Cross Instance Call',
		 'CS',': Control File Schema',
		 'CU',': Bind Enqueue',
		 'DF',': Data File',
		 'DL',': Direct-loader index-creation',
		 'DM',': Mount/startup db primary/secondary instance',
		 'DR',': Distributed Recovery Process',
		 'DX',': Distributed Transaction Entry',
		 'FI',': SGA Open-File Information',
		 'FS',': File Set',
		 'IN',': Instance Number',
		 'IR',': Instance Recovery Serialization',
		 'IS',': Instance State',
		 'IV',': Library Cache InValidation',
		 'JQ',': Job Queue',
		 'KK',': Redo Log "Kick"',
		 'LS',': Log Start/Log Switch',
		 'MB',': Master Buffer hash table',
		 'MM',': Mount Definition',
		 'MR',': Media Recovery',
		 'PF',': Password File',
		 'PI',': Parallel Slaves',
		 'PR',': Process Startup',
		 'PS',': Parallel Slaves Synchronization',
		 'RE',': USE_ROW_ENQUEUE Enforcement',
		 'RT',': Redo Thread',
		 'RW',': Row Wait',
		 'SC',': System Commit Number',
		 'SH',': System Commit Number HWM',
		 'SM',': SMON',
		 'SQ',': Sequence Number',
		 'SR',': Synchronized Replication',
		 'SS',': Sort Segment',
		 'ST',': Space Transaction',
		 'SV',': Sequence Number Value',
		 'TA',': Transaction Recovery',
		 'TD',': DDL enqueue',
		 'TE',': Extend-segment enqueue',
		 'TM',': DML enqueue',
		 'TS',': Temporary Segment',
		 'TT',': Temporary Table',
		 'TX',': Transaction',
		 'UL',': User-defined Lock',
		 'UN',': User Name',
		 'US',': Undo Segment Serialization',
		 'WL',': Being-written redo log instance',
		 'WS',': Write-atomic-log-switch global enqueue',
		 'XA',': Instance Attribute',
		 'XI',': Instance Registration',
		 decode(substr(type,1,1),
			'L', ': Library Cache ('||substr(type,2,1)||')',
			'N', ': Library Cache Pin ('||substr(type,2,1)||')',
			'Q', ': Row Cache ('||substr(type,2,1)||')',
			     ': ????')),
          DECODE(LMODE,
                 0, '--Waiting--',
                 1, 'Null',
                 2, 'Sub-Share',
                 3, 'Sub-Exclusive',
                 4, 'Share',
                 5, 'Share/Sub-Excl',
                 6, 'Exclusive',
		         '<Unknown>'),
          DECODE(REQUEST,
                 0, '',
                 1, 'Null',
                 2, 'Sub-Share',
                 3, 'Sub-Exclusive',
                 4, 'Share',
                 5, 'Share/Sub-Excl',
                 6, 'Exclusive',
		         '<Unknown>')

spool locks_&&V_INSTANCE
/
spool off
