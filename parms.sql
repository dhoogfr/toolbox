----------------------------------------------------------------------------------------
--
-- File name:   parms.sql
-- Purpose:     Display parameters and values.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values, all of which can be left blank.
--
--              name: the name (or piece of a name) of the parameter(s) you wish to see
--
--              isset: "TRUE" or "T" to see only nondefault parameters 
--
--              show_hidden: "Y" to show hidden parameters as well
--
---------------------------------------------------------------------------------------
set lines 155
col name for a50
col value for a70
col isdefault for a8
col ismodified for a10
col isset for a10
select name, value, isdefault, ismodified, isset
from
(
select flag,name,value,isdefault,ismodified,
case when isdefault||ismodified = 'TRUEFALSE' then 'FALSE' else 'TRUE' end isset 
from
   (
       select 
            decode(substr(i.ksppinm,1,1),'_',2,1) flag
            , i.ksppinm name
            , sv.ksppstvl value
            , sv.ksppstdf  isdefault
--            , decode(bitand(sv.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismodified
            , decode(bitand(sv.ksppstvf,7),1,'TRUE',4,'TRUE','FALSE') ismodified
         from sys.x$ksppi  i
            , sys.x$ksppsv sv
        where i.indx = sv.indx
   )
)
where name like nvl('%&parameter%',name)
and upper(isset) like upper(nvl('%&isset%',isset))
and flag not in (decode('&show_hidden','Y',3,2))
order by flag,replace(name,'_','')
/
