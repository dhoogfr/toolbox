set verify off

accept l_user char prompt 'username: '
accept l_pass char prompt 'password: '
accept l_tablespace char prompt 'tablespace: '
accept l_quota number prompt 'quota (in MB) on tablespace: '
accept l_temp_tablespace char prompt 'temporary tablespace: '


create user &&l_user identified by &l_pass
    default tablespace &&l_tablespace
    temporary tablespace &&l_temp_tablespace
    quota &&l_quota.M ON &&l_tablespace
/

grant create session to &&l_user;
grant create table to &&l_user;
grant create view to &&l_user;
grant create trigger to &&l_user;
grant create procedure to &&l_user;
grant create type to &&l_user;
grant create sequence to &&l_user;
grant create synonym to &&l_user;
grant query rewrite to &&l_user;
exit;
