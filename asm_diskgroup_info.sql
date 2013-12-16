set linesize 150

column compatibility format a15
column db_compatibility format a15
column au_size_mb format 99D99
column total_mb format 999G999G999D99
column free_mb format 9G999G999D99
column usable_file_mb format 9G999G999D99
column req_m_free_mb format 9G999G999D99
column name format a15

select
  name, type, sector_size, block_size, total_mb, free_mb, 
  required_mirror_free_mb req_m_free_mb, usable_file_mb,
  (allocation_unit_size/1024/1024) au_size_mb, 
  compatibility, 
  database_compatibility db_compatibility
from
  v$asm_diskgroup 
order by
  name
;
