set linesize 200
set pages 9999

column bdummy noprint

col qcinst_id                   format 999      heading "Coordinator|Instance"
col qcsid                       format 9999     heading "Coordinator|Sid"
col qcserial#                   format 99999    heading "Coordinator|Serial#"
col username                    format a20      heading "Username"
col sql_id                      format a20      heading "SQL id"
col resource_consumer_group     format a30      heading "Consumer Group"
col inst_id                     format 999      heading "Slave|Instance"
col server_group                format 9999     heading "Slave|Group"
col server_set                  format 9999     heading "Slave|Set"
col req_degree                  format 9999     heading "Req|Degree"
col degree                      format 9999     heading "Degree"
col queued                      format a16      heading "Queued"

break on resource_consumer_group skip 1 -
      on bdummy  -
      on qcinst_id -
      on qcsid -
      on qcserial# -
      on username -
      on sql_id -
      on inst_id -
      on server_group -
      on server_set

select
  distinct
  sess.resource_consumer_group,
  (pxs.qcinst_id || pxs.qcsid || pxs.qcserial#) bdummy,
  pxs.qcinst_id,
  pxs.qcsid,
  pxs.qcserial#,
  sess.username,
  sess.sql_id,
  pxs.server_group,
  pxs.inst_id,
  pxs.server_set,
  pxs.req_degree,
  pxs.degree
from
  gv$px_session     pxs,
  gv$session        sess
where
  pxs.qcinst_id = sess.inst_id
  and pxs.qcsid = sess.sid
  and qcinst_id is not null
order by
  resource_consumer_group,
  qcinst_id,
  qcsid,
  inst_id,
  server_group,
  server_set
;

clear breaks
column bdummy clear
