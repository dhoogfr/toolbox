with
  sci as
  ( select
      distinct
      inst_id,
      sid,
      serial#,
      client_charset,
      client_driver
    from
      gv$session_connect_info
  )
select
  sci.client_charset,
  sci.client_driver,
  ses.program,
  ses.machine,
  count(*) counted
from
  sci
    inner join gv$session         ses
      on ( sci.inst_id = ses.inst_id
           and sci.sid = ses.sid
           and sci.serial# = ses.serial#
         )
where
  ses.type != 'BACKGROUND'
group by
  sci.client_charset,
  sci.client_driver,
  ses.program,
  ses.machine
order by
  sci.client_charset,
  sci.client_driver,
  ses.program,
  ses.machine
;





with
  sci as
  ( select
      distinct
      inst_id,
      sid,
      serial#,
      client_oci_library
    from
      gv$session_connect_info
  )
select
  sci.client_oci_library,
  ses.program,
  ses.machine,
  count(*) counted
from
  sci
    join gv$session         ses
      on ( sci.inst_id = ses.inst_id
           and sci.sid = ses.sid
           and sci.serial# = ses.serial#
         )
where
  ses.type != 'BACKGROUND'
group by
  sci.client_oci_library,
  ses.program,
  ses.machine
order by
  sci.client_oci_library,
  ses.program,
  ses.machine
;
