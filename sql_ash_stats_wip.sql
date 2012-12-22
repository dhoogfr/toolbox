set linesize 210
set pages 50000

column inst_id          format 9999               heading "inst"
column sample_id        format 999999             heading "sample"
column sample_time      format a20                heading "sample time"
column session_id       format 99999              heading "sess"
column qc_instance_id   format 9999               heading "qc|inst"
column qc_session_id    format 99999              heading "qc|sess"
column session_state    format a7                 heading "state"
column event            format a35                heading "event"
column par1             format a30                heading "p1"
column par2             format a30                heading "p2"
column par3             format a30                heading "p3"
column time_waited      format 999G999G999G999    heading "time waited µs"

break on instance_id skip 1 on sample_id on sample_time

select
  ash.inst_id,
  ash.sample_id,
  to_char(ash.sample_time, 'DD/MM/YYYY HH24:MI:SS') sample_time,
  ash.qc_instance_id,
  ash.qc_session_id,
  ash.session_id,
  ash.session_state,
  ash.event,
  (ash.p1text || ': ' || ash.p1) par1,
  (ash.p2text || ': ' || ash.p2) par2,
  (ash.p3text || ': ' || ash.p3) par3,
  ash.time_waited
from
  gv$active_session_history   ash
where
  ash.sql_id = '&sql_id'
  and ash.sample_time between
    to_date('&bdate', 'DD/MM/YYYY HH24:MI')
    and to_date('&edate', 'DD/MM/YYYY HH24:MI')
order by
  ash.inst_id,
  ash.sample_id,
  ash.qc_instance_id,
  ash.qc_session_id,
  ash.session_id
;

clear breaks
