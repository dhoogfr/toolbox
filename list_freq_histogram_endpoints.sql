-- WIP

select endpoint_actual_value row_value,
       curr_num - nvl(prev_num,0) row_count
from ( select endpoint_actual_value,
              endpoint_number curr_num,
              lag(endpoint_number,1) over
                ( order by endpoint_number
                ) prev_num
       from dba_tab_histograms
       where owner = 'FDH'
             and table_name = 'F4102'
             and column_name = 'IBMCU'
     )
order by endpoint_actual_value
;



select endpoint_actual_value row_value,
       curr_num - nvl(prev_num,0) row_count
from ( select endpoint_actual_value,
              endpoint_number curr_num,
              lag(endpoint_number,1) over
                ( order by endpoint_number
                ) prev_num
       from dba_tab_histograms
       where owner = 'SYS'
             and table_name = 'QUICKY'
             and column_name = 'VELD1'
     )
order by endpoint_actual_value
;


select to_date(endpoint_actual_value, 'DD-MON-YY') row_value,
       curr_num - nvl(prev_num,0) row_count
from ( select endpoint_actual_value,
              endpoint_number curr_num,
              lag(endpoint_number,1) over
                ( order by endpoint_number
                ) prev_num
       from dba_tab_histograms
       where owner = 'DWHMANAGER'
             and table_name = 'SIGNALITIEK'
             and column_name = 'SNAPSHOTDATUM'
     )
order by row_value
;