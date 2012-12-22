exec dbms_monitor.serv_mod_act_trace_enable(service_name => 'NAVIS_TRACING', WAITS => TRUE, BINDS => TRUE);

BEGIN

    for l_sessions in
        ( select sid, serial#
          from v$session
          where service_name ='NAVIS_TRACING'
        )       
    loop
    
        dbms_monitor.session_trace_enable
            ( session_id    => l_sessions.sid,
              serial_num    => l_sessions.serial#,
              waits         => true,
              binds         => true
            );
            
   end loop;
   
END;
/
