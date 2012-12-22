whenever sqlerror exit 
column password new_value pw 

declare 
    l_passwd varchar2(45); 
begin 
    select password into l_passwd 
      from sys.dba_users 
     where username = upper('&1'); 
end; 
/ 

select password 
  from sys.dba_users 
 where username = upper( '&1' ) 
/ 

alter user &1 identified by Hello; 
connect &1/hello 
alter user &1 identified by values '&pw'; 
show user 
whenever sqlerror continue
