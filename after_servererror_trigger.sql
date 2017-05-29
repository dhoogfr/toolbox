drop sequence log_errors_seq;
 
create sequence log_errors_seq
    start with 1
    increment by 1
    minvalue 1
    nomaxvalue
    nocache
    nocycle;

drop table log_errors_tab;
 
create table log_errors_tab 
( id            number,
  log_date      date,
  err_msg       clob,
  stm           clob,
  username      varchar2(30)
)
tablespace sysaux;
 
  
create or replace trigger log_errors_trig after servererror on database

DECLARE

    id          number;
--    v_user      varchar2(30);
--    v_os        varchar2(30);
--    v_prog      varchar2(30);
--    v_cur       varchar2(100);
--    v_sql       varchar2(2000);
    stmt        varchar2 (2000);
    sql_text    ora_name_list_t;
    l           binary_integer ;

BEGIN

    select log_errors_seq.nextval 
    into id 
    from dual;

    l := ora_sql_txt(sql_text);

    for i in 1..l loop
        stmt :=stmt||sql_text(i);
    end loop;

    for n in 1..ora_server_error_depth loop
        insert into log_errors_tab (id, log_date, err_msg, stm, username)
        values (id, sysdate, ora_server_error_msg(n),stmt, ora_login_user);
    end loop;

EXCEPTION

  -- not pretty, but....
  -- avoid blocking programs because of malfunctioning error logging
  when others then
    null;


END LOG_ERRORS_TRIG;
/