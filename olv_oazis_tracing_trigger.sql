create or replace trigger trace_facturatie
after logon on database
BEGIN

    if ( sysdate between 
           to_date('19/07/2012 12:00','DD/MM/YYYY HH24:MI')
           and to_date('19/07/2012 17:00','DD/MM/YYYY HH24:MI')
         and ( sys_context('USERENV', 'IP_ADDRESS') = '172.16.254.102'
               or sys_context('USERENV', 'IP_ADDRESS') = '172.16.247.15'
             )
         and upper(trim(sys_context('USERENV', 'OS_USER'))) = 'FACTURATIE'
       )
    then
        
        dbms_monitor.session_trace_enable
          ( waits       =>  true,
            binds       =>  true,
            plan_stat   =>  'ALL_EXECUTIONS'
          );
          
    end if;
    
EXCEPTION
    when others
    then
        null;
    
END;
/