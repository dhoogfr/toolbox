/* list the optimizer statistic operation tasks
   
   The script will ask for an optionally filter on the operation id (can be listed via the list_optstat_history.sql script)
   and an optional filter on the target name (supports wildcards) and the start time (DD/MM/YYYY)
   It will also ask if the notes column needs to be displayed (this is a large xml, so best only when filtering)
*/

set linesize 300
set pages 50000

set verify off
column target format a64
column target_type format a25
column nbr_blocks format 9G999G999G999
column start_time_str format a30
column end_time_str format a30
column status format a15
column duration format a15
column estimated_cost format 999G999
column notes_xml format a220

accept opid_filter number prompt "Filter on opertions id: "
accept target_filter char prompt "Filter on target: "
accept starttime_filter char prompt "Filter on start time (DD/MM/YYYY): "
accept display_notes char default 'NO' prompt "Display notes column (YES|NO, default NO): "

var c_result refcursor
set autoprint on
set serveroutput on

set feedback off

DECLARE

  l_filter  varchar2(200);
  l_where   varchar2(10);
  l_concat  varchar2(10);
  l_query   clob;

BEGIN

  if &opid_filter != 0 then
    l_where := ' where ';
    l_filter := 'opid = &opid_filter';
    l_concat := ' and ';
  end if;

  if '&target_filter' is not null then
    l_where := ' where ';
    l_filter := l_filter || l_concat || 'target like ''&target_filter''';
    l_concat := ' and ';
  end if;

  if '&starttime_filter' is not null then
    l_where := ' where ';
    l_filter := l_filter || l_concat || 'start_time >= to_date(''&starttime_filter'', ''DD/MM/YYYY'')';
  end if;

  l_query := q'[select
      opid,
      target,
      target_type,
      target_size nbr_blocks,
      to_char(start_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') start_time_str,
      to_char(end_time, 'DD/MM/YYYY HH24:MI:SS TZH:TZM') end_time_str,
      cast ((end_time - start_time) as interval day(2) to second(0)) duration,
      status,
      estimated_cost,
      priority ]';

  if upper('&display_notes') = 'YES'
  then
    l_query := l_query ||  q'[ ,xmlserialize(content xmltype(nvl2(notes, notes, '<notes/>')) as clob indent size = 2) notes_xml ]';
  end if;

  l_query := l_query || 'from dba_optstat_operation_tasks' || l_where || l_filter || ' order by start_time, end_time';

  open :c_result for
    l_query; 

END;
/

set feedback 6

undef opid_filter
undef target_filter
undef starttime_filter