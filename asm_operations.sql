select
  g.name, 
  o.operation, 
  o.state, 
  o.sofar, 
  o.est_work, 
  o.est_minutes, 
  power
from 
  v$asm_diskgroup g, 
  v$asm_operation o
 where
   o.group_number = g.group_number
;
