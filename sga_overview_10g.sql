set linesize 120
set pagesize 9999

column component format a40
column curr_mb format 99G999D99
column min_mb format 99G999D99
column max_mb format 99G999D99
column user_mb format 99G999D99
column granule_mb format 99G999D99

compute sum of curr_mb on report

break on report

select component, current_size/1024/1024 curr_mb, min_size/1024/1024 min_mb, max_size/1024/1024 max_mb, 
       user_specified_size/1024/1024 user_mb, granule_size/1024/1024 granule_mb
from v$sga_dynamic_components
order by component;

clear breaks
