set pages 50000
set linesize 300

set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6


column pdb format a30
column name format a30
column network_name format a30

break on pdb duplicates skip 1

select
  pdb, 
  name, 
  network_name 
from
  cdb_services
where
  pdb like nvl('&1', '%')
order by 
  pdb, 
  name
;

clear breaks

undef 1
