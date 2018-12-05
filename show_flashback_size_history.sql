-- shows the recent history of flashback log generation in 1 hour time periods
-- db data is the number of database bytes read / written during that time period

column begin_time_str format a18
column end_time_str format a18
column flashback_data_mb format 999G990D99
column db_data_gb format 990D99
column redo_data_mb format 999G990D99
column estimated_flashback_size_gb format 990D99

select 
  to_char(begin_time, 'DD/MM/YYYY HH24:MI')     begin_time_str, 
  to_char(end_time, 'DD/MM/YYYY HH24:MI')       end_time_str, 
  flashback_data/1024/1024                      flashback_data_mb, 
  db_data/1024/1024/1024                        db_data_gb, 
  redo_data/1024/1024                           redo_data_mb, 
  estimated_flashback_size/1024/1024/1024       estimated_flashback_size_gb 
from
  v$flashback_database_stat
order by
  begin_time
;
