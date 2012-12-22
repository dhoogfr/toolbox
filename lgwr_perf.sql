column event format a30
column time_waited_micro format 999999999999999999
column time_waited_micro_fg format 999999999999999999

select to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS') my_time, event, total_waits, total_timeouts, time_waited_micro, time_waited_micro_fg from v$system_event where event in ('log file sync', 'log file parallel write');
select to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS') my_time, name, value from v$sysstat where name in ('redo write time', 'user commits') order by name;
