exec dbms_monitor.serv_mod_act_trace_disable(service_name => 'NAVIS_TRACING');

BEGIN

    for l_sessions in
        ( select sid, serial#
          from v$session
          where service_name ='NAVIS_TRACING'
                and sql_trace = 'ENABLED'
        )
        
    loop
    
        dbms_monitor.session_trace_disable
            ( session_id    => l_sessions.sid,
              serial_num    => l_sessions.serial#
            );
            
   end loop;
   
END;
/
