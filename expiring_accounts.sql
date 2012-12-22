column username format a30
column profile format a20
column account_status format a15
column creation_date format a20
column expiry_date format a11


select
  username, profile, account_status, 
  to_char(created, 'DD/MM/YYYY HH24:MI:SS') creation_date, 
  to_char(expiry_date, 'DD/MM/YYYY') expiry_date
from
  dba_users
where
  ( account_status = 'EXPIRED'
    or account_status = 'EXPIRED(GRACE)'
  )
  or ( account_status = 'OPEN'
       and expiry_date is not null
     )
order by
  username
;
