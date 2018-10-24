set linesize 300
set pagesize 50000
set tab off

break on inst_id dup skip page

column shared_pool_size_for_estimate format 9G999G999
column shared_pool_size_factor format 0D0000
column estd_lc_size format 9G999G999
column estd_lc_memory_objects format 9G999G999
column estd_lc_time_saved format 999G999G999
column est_lc_time_saved_factor format 0D0000
column estd_lc_load_time format 9G999G999G999
column estd_lc_load_time_factor format 9990D0000
Column estd_lc_memory_object_hits format 999G999G999G999

select
  inst_id,
  shared_pool_size_for_estimate,
  shared_pool_size_factor,
  estd_lc_size,
  estd_lc_memory_objects,
  estd_lc_time_saved,
  estd_lc_time_saved_factor,
  estd_lc_load_time,
  estd_lc_load_time_factor,
  estd_lc_memory_object_hits
from
  gv$shared_pool_advice
order by
  inst_id,
  shared_pool_size_factor
;

clear breaks
