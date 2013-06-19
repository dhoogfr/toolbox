-- overview of the number of optimal / onepass / multipass sorts per workarea histogram bucket
-- translating the low / high_optimal_size number into human readable units

column low_optimal_size_h format a15 justify right
column high_optimal_size_h format a15 justify right
column optimal_executions format 999G999G999G999
column onepass_executions format 999G999G999G999
column multipass_executions format 999G999G999G999
column total_executions format 999G999G999G999

break on inst_id skip 1

select
  inst_id,
  case
    when low_optimal_size >= 1099511627776 then to_char(low_optimal_size/1024/1024/1024/1024, '999G990D99') || ' TB' 
    when low_optimal_size >= 1073741824 then to_char(low_optimal_size/1024/1024/1024, '999G990D99') || ' GB'
    when low_optimal_size >= 1048576 then to_char(low_optimal_size/1024/1024, '999G990D99') || ' MB'
    when low_optimal_size >= 1024 then to_char(low_optimal_size/1024, '999G990D99') || ' KB'
    else to_char(low_optimal_size, '999G990D99')
  end as low_optimal_size_h,
  case
    when high_optimal_size >= 1099511627776 then to_char(high_optimal_size/1024/1024/1024/1024, '999G990D99') || ' TB' 
    when high_optimal_size >= 1073741824 then to_char(high_optimal_size/1024/1024/1024, '999G990D99') || ' GB'
    when high_optimal_size >= 1048576 then to_char(high_optimal_size/1024/1024, '999G990D99') || ' MB'
    when high_optimal_size >= 1024 then to_char(high_optimal_size/1024, '999G990D99') || ' KB'
    else to_char(high_optimal_size, '999G990D99')
  end as high_optimal_size_h,
  optimal_executions, 
  onepass_executions, 
  multipasses_executions, 
  total_executions 
from 
  gv$sql_workarea_histogram 
order by
  inst_id, 
  low_optimal_size
;

clear breaks
