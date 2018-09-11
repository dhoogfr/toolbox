set verify off

column name format a40
column value format a25
column default_value format a25
column description format a40 word_wrapped
set linesize 250

select ksppinm name, ksppstvl value, ksppstdf isdefault, ksppstdfl default_value, x.inst_id inst_id, ksppdesc description
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ksppinm like '&name'
order by ksppinm, x.inst_id;

undef name
