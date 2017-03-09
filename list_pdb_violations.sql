set pages 50000
set linesize 300

set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column name format a30
column time_str format a20
column status format a10
column cause format a40 word_wrapped
column message format a110 word_wrapped

select
  name,
  to_char(time, 'DD/MM/YYYY HH24:MI:SS') time_str,
  status,
  cause,
  message
from
  pdb_plug_in_violations
where
  status != 'RESOLVED'
  and name like nvl('&1', '%')
order by
  name,
  time
;

undef 1
