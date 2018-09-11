create or replace trigger trace_carenet 
after logon on database
BEGIN

    if sys_context('USERENV', 'IP_ADDRESS') = '10.10.6.185'
       and trunc(sysdate) = to_date('09/09/2005')
    then
        execute immediate 'alter session set max_dump_file_size=''1000M''';
        execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
    end if;
    
EXCEPTION
    when others
    then
        null;
    
END;
/
