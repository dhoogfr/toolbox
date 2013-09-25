-- uses the aud$ data to generate a list of all incoming database links
-- the accurateness of the list depends on how long the audit data is stored and inactive db links will not show up in this list

set linesize 250

column globalname format a30
column userhost format a40
column userid format a30
column first_connection format a20
column last_connection format a20
column cnt_connections format 9G999G999G999

break on globalname on userhost

with
  incoming as
    ( select 
        regexp_replace(comment$text, '.*=(.*)\..*', '\1') globalname,
        userhost,
        userid,
        ntimestamp#
      from 
        sys.aud$ 
      where 
        comment$text like 'DBLINK%' 
    )
select
  globalname,
  userhost,
  userid,
  to_char(min(ntimestamp#),'DD/MM/YYYY HH24:MI') first_connection,
  to_char(max(ntimestamp#), 'DD/MM/YYYY HH24:MI') last_connection,
  count(*) cnt_connections
from
  incoming  
group by
  globalname,
  userhost,
  userid
order by
  globalname,
  userhost,
  userid
;

clear breaks
