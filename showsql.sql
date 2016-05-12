------ begin of showsql.sql --------------------------

column status format a10
set feedback off
set serveroutput on

select username, sid, serial#, process, status
from v$session
where username is not null
/

column username format a20
column sql_text format a55 word_wrapped

set serveroutput on size 1000000
declare
    x number;
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,' Day HH24:MI') logon_time,
             to_char(sysdate,' Day HH24:MI') current_time,
             sql_address, LAST_CALL_ET
        from v$session
       where status = 'ACTIVE'
         and rawtohex(sql_address) <> '00'
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 4)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( x.username );
                dbms_output.put_line( x.logon_time || ' ' ||
                                      x.current_time||
                                      ' last et = ' ||
                                      x.LAST_CALL_ET);
                dbms_output.put_line(
                          substr( y.sql_text, 1, 250 ) );
            end if;
        end loop;
    end loop;
end;
/

column username format a15 word_wrapped
column module format a15 word_wrapped
column action format a15 word_wrapped
column client_info format a30 word_wrapped

select username||'('||sid||','||serial#||')' username,
       module,
       action,
       client_info
from v$session
where module||action||client_info is not null;

------------------------ eof --------------------------