set linesize 120
column SL_MB format 999G999D99
column SU_MB format 999G999D99
column SR_MB format 999G999D99
column SF_MB format 999G999D99
column SF_PCT format 999D00
column nbr_files format 9G999G999G999
column name format a30

select name, space_limit/1024/1024 SL_MB, space_used/1024/1024 SU_MB, space_reclaimable/1024/1024 SR_MB, 
       (space_limit -  space_used + space_reclaimable)/1024/1024 SF_MB, (100 * (space_limit -  space_used + space_reclaimable)/space_limit ) SF_PCT,
       number_of_files nbr_files
from v$recovery_file_dest;