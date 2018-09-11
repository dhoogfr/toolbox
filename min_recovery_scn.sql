-- get the scn beyond which you must recover to clear datafile fuzziness

column beyond_scn format 99999999999999999

select
  max(checkpoint_change#) beyond_scn, 
  to_char(max(checkpoint_time), 'DD/MM/YYYY HH24:MI:SS') beyond_time
from
  v$backup_datafile
where
  resetlogs_time =
    ( select
        resetlogs_time
      from
        v$database_incarnation
      where
        status = 'CURRENT'
    )
;

