set linesize 200
set pages 9999

col username            format a20      heading "Username"
col service_name        format a15      heading "Service"
col original_cg         format a30      heading "Original|Consumer Group"
col mapped_cg           format a30      heading "Mapped|Consumer Group"
col current_cg          format a30      heading "Current|Consumer Group"
col mapping_attribute   format a20      heading "Mapping|Attribute"
col state               format a15      heading "State"
col counted             format 9G999    heading "Counted"

break on username on service_name

select
  sess.username,
  sess.service_name,
  cg2.consumer_group            original_cg,
  rsess.mapped_consumer_group   mapped_cg,
  cg1.consumer_group            current_cg,
  rsess.mapping_attribute,
  rsess.state,
  count(*) counted
from
  gv$rsrc_session_info      rsess,
  gv$session                sess,
  dba_rsrc_consumer_groups  cg1,
  dba_rsrc_consumer_groups  cg2
where
  rsess.inst_id = sess.inst_id
  and rsess.sid = sess.sid
  and rsess.current_consumer_group_id = cg1.consumer_group_id
  and rsess.orig_consumer_group_id = cg2.consumer_group_id
group by
  sess.username,
  sess.service_name,
  rsess.mapping_attribute,
  cg1.consumer_group,
  cg2.consumer_group,
  rsess.mapped_consumer_group,
  rsess.state
order by
  sess.username,
  sess.service_name,
  original_cg,
  mapped_cg,
  current_cg,
  state
;

clear breaks
