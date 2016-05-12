select endpoint_value row_value,
       curr_num - nvl(prev_num,0) row_count
from ( select endpoint_value,
              endpoint_number curr_num,
              lag(endpoint_number,1) over
                ( order by endpoint_number
                ) prev_num
       from dba_tab_histograms
       where owner = '&T_OWNER'
             and table_name = '&T_TABLE'
             and column_name = '&T_COLUMN'
     )
order by endpoint_value;
