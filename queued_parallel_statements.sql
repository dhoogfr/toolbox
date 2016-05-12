set linesize 200
set pages 9999

col resource_consumer_group     format a25          heading "Consumer Group Name"
col username                    format a20          heading "Username"
col inst_id                     format 999          heading "Instance"
col sql_id                      format a20          heading "SQL id"
col sid                         format 99999        heading "Sid"
column queued                   format a25          heading "Queue"
column seconds_in_wait          format 9G999G999    heading "Seconds|Waited"

break on resource_consumer_group skip 1 on queued

select
  resource_consumer_group, 
    ( case event 
        when 'resmgr:pq queued' then 'RSRC Queue' 
        when 'PX Queuing: statement queue' then 'Statement Queue, Next' 
        when 'ENQ JX SQL statement queue' then 'Statement Queue' 
      end
    ) queued,
  seconds_in_wait,
  username, inst_id, sid, sql_id
from
  gv$session 
where
  event in
    ( 'resmgr:pq queued', 'PX Queuing: statement queue', 'ENQ JX SQL statement queue')
order by
  resource_consumer_group,
  queued,
  seconds_in_wait desc
;
   
clear breaks
