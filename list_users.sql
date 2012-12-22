set linesize 150
set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column username format a20
column created format a10
column lock_date format a10
column expiry_date format a10
column profile format a20
column account_status format a25
column default_tablespace format a20
column temporary_tablespace format a20

select
  username,
  to_char(created, 'DD/MM/YYYY') created,
  profile,
  account_status,
  to_char(lock_date,'DD/MM/YYYY') lock_date,
  to_char(expiry_date,'DD/MM/YYYY') expiry_date,
  default_tablespace,
  temporary_tablespace
from
  dba_users
where
  username like nvl('&1', '%')
order by
  username
;

undef 1
