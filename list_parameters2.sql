set linesize 180
set pagesize 9999
COLUMN value FORMAT a40 word_wrapped
COLUMN name FORMAT a35
column inst_id format 99999

select x.inst_id inst_id, ksppinm name, ksppstvl value, ksppstdf isdefault
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ( ksppstdf = 'FALSE'
            or translate(ksppinm,'_','#') like '##%' 
          --  or translate(ksppinm,'_','#') like '#%'
          )
order by x.inst_id, ksppinm;
