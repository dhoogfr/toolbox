set linesize 130
set pages 50000

column dg_number        format 999999999    heading "dg number"
column dg_name          format a30          heading "dg name"
column attr_name        format a40          heading "attribute name"
column attr_value       format a40          heading "attribute value"
column attr_incarnation format 99999        heading "incar"

break on dg_number skip 1 on dg_name

select
  dg.group_number             dg_number,
  dg.name                     dg_name,
  attr.name                   attr_name, 
  attr.value                  attr_value,
  attr.attribute_incarnation  attr_incarnation
from
  v$asm_attribute     attr,
  v$asm_diskgroup     dg
where
  attr.group_number = dg.group_number
  and attr.name not like 'template%'
order by
  dg.group_number,
  attr.name,
  attr.attribute_incarnation
;

clear breaks
