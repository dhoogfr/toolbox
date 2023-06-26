--Apex session queries

--alter session set container = RXSPRD;


SELECT *
FROM   apex_workspace_log_summary_usr
WHERE  workspace = 'RXPRD'
AND apex_user != 'nobody'
AND last_view > sysdate - 60 / 24 / 60;

select apex_user as who
  ,application_id||':'||page_id as what
  ,view_date as when
  ,elapsed_time as how_long
  ,page_view_type as why
  ,request_value as more_why
from apex_workspace_activity_log
where application_id = 1000
and apex_user != 'nobody'
order by how_long desc
;


SELECT
workspace_name,
apex_session_id,
user_name,
remote_addr,
TO_CHAR(session_created, 'DD-MON-YYYY HH24:MI') AS session_created,
TO_CHAR(session_idle_timeout_on, 'DD-MON-YYYY HH24:MI') AS session_idle_timeout_on,
TO_CHAR(session_idle_timeout_on-(session_max_idle_sec/24/60/60), 'DD-MON-YYYY HH24:MI') AS last_activity,
TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI') AS time_now,
round((sysdate-(session_idle_timeout_on-(session_max_idle_sec/24/60/60)))*24*60) as minutes_ago
 FROM apex_workspace_sessions
WHERE user_name NOT IN ('APEX_PUBLIC_USER','nobody') 
and workspace_name = 'RXPRD'
ORDER BY minutes_ago, workspace_name, session_idle_timeout_on DESC
;

SELECT
remote_addr,
user_name,
min(session_created),
max(session_created),
count(*)
 FROM apex_workspace_sessions
WHERE user_name IN ('APEX_PUBLIC_USER','nobody') 
and workspace_name = 'RXPRD'
group by remote_addr, user_name
ORDER BY remote_addr, user_name
;



select username pool, count(*) counted
from v$session 
where username in ('APEX_LISTENER', 'APEX_PUBLIC_USER', 'APEX_REST_PUBLIC_USER', 'ORDS_PUBLIC_USER')
group by username 
order by 1;


