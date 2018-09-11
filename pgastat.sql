column name format a40
column value_h format 9G999G999G999G999G999D99

break on name skip 1

select
  name,
  inst_id,
  case
    when unit = 'bytes' then
      case
        when value >= 1099511627776 then value/1024/1024/1024/1024 
        when value >= 1073741824 then value/1024/1024/1024
        when value >= 1048576 then value/1024/1024
        when value >= 1024 then value/1024
        else value
      end
    else
      value
  end as value_h,
  case
    when unit = 'bytes' then
      case
        when value >= 1099511627776 then 'TB'
        when value >= 1073741824 then 'GB'
        when value >= 1048576 then 'MB'
        when value >= 1024 then 'KB'
        else 'B'
      end
    else
      unit
  end as unit_h
from
  gv$pgastat
order by
  name,
  inst_id
;
