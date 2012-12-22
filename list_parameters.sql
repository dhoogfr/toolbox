-- alles
select x.inst_id inst_id,x.indx+1 num,ksppinm name,ksppity type,
       ksppstvl value, ksppstdvl display_value, ksppstdf isdefault,
       decode(bitand(ksppiflg/256,1),1,'TRUE','FALSE') isses_modifiable,  
       decode(bitand(ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') issys_modifiable,
       decode(bitand(ksppiflg,4),4,'FALSE',decode(bitand(ksppiflg/65536,3), 0, 'FALSE','TRUE')) isinstance_modifiable, 
       decode(bitand(ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismodified,  
       decode(bitand(ksppstvf,2),2,'TRUE','FALSE') isadjusted,  
       decode(bitand(ksppilrmflg/64, 1), 1, 'TRUE', 'FALSE') isdeprecated,  
       ksppdesc description, ksppstcmnt update_comment, ksppihash hash
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)


-- gewijzigde + _
set linesize 180
set pagesize 9999
COLUMN display_value FORMAT a15 word_wrapped
COLUMN value FORMAT a15 word_wrapped
COLUMN name FORMAT a35
COLUMN update_comment FORMAT a15 word_wrapped
COLUMN description ON FORMAT a20 word_wrapped

select x.inst_id inst_id,ksppinm name,ksppity type,
       ksppstvl value, ksppstdf isdefault,
       decode(bitand(ksppiflg/256,1),1,'TRUE','FALSE') isses_modifiable,  
       decode(bitand(ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') issys_modifiable,
       decode(bitand(ksppiflg,4),4,'FALSE',decode(bitand(ksppiflg/65536,3), 0, 'FALSE','TRUE')) isinstance_modifiable, 
       decode(bitand(ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismodified,  
       decode(bitand(ksppstvf,2),2,'TRUE','FALSE') isadjusted,  
       decode(bitand(ksppilrmflg/64, 1), 1, 'TRUE', 'FALSE') isdeprecated,  
       ksppdesc description, ksppstcmnt update_comment
from  x$ksppi x, x$ksppcv y
where (x.indx = y.indx)
      and ( ksppstdf = 'FALSE'
            or translate(ksppinm,'_','#') like '##%' 
          --  or translate(ksppinm,'_','#') like '#%'
          )
order by x.inst_id, ksppinm;
