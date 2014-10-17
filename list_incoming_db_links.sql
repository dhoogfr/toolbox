-- uses the aud$ data to generate a list of all incoming database links
-- the accurateness of the list depends on how long the audit data is stored and inactive db links will not show up in this list

set linesize 250

column source_globalname format a30
column dblink_name format a50
column source_host format a40
column dest_schema format a30
column first_connection format a20
column last_connection format a20
column cnt_connections format 9G999G999G999

break on source_globalname on dblink_name on userhost

with
  incoming as
    ( select 
        regexp_replace(comment$text, '.*SOURCE_GLOBAL_NAME=(([^,]+)),.*', '\1') source_globalname,
        regexp_replace(comment$text, '.*DBLINK_NAME=(([^,]+)),.*', '\1') dblink_name,
        userhost source_host,
        userid dest_schema,
        ntimestamp#
      from 
        sys.aud$ 
      where 
        comment$text like 'DBLINK%' 
    )
select
  source_globalname,
  dblink_name,
  source_host,
  dest_schema,
  to_char(min(ntimestamp#),'DD/MM/YYYY HH24:MI') first_connection,
  to_char(max(ntimestamp#), 'DD/MM/YYYY HH24:MI') last_connection,
  count(*) cnt_connections
from
  incoming  
group by
  source_globalname,
  dblink_name,
  source_host,
  dest_schema
order by
  source_globalname,
  dblink_name,
  source_host,
  dest_schema
;

clear breaks

