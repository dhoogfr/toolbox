column counted format 9G999G999G999

accept OWNER prompt 'Owner Name: '

break on report on stattype_locked skip 2 on last_analyzed_day skip 1

compute sum of counted on last_analyzed_day 
compute sum of counted on stattype_locked 
compute sum of counted on report

select
  stattype_locked,
  trunc(last_analyzed) last_analyzed_day,
  object_type,
  count(*) counted
from 
  ( select
      object_type, 
      last_analyzed,
      stattype_locked
    from
      dba_tab_statistics
    where
      owner = '&OWNER'
      and table_name not in
        ( select
            table_name
          from
            dba_external_tables
          where
            owner = '&OWNER'
          union all
          select
            table_name
          from
            dba_tables
          where
            temporary = 'Y'
            and owner = '&OWNER'
        )
    union all
    select
      object_type, 
      last_analyzed,
      stattype_locked
    from
      dba_ind_statistics
    where
      owner = '&OWNER'
      and table_name not in
        ( select
            table_name
          from
            dba_external_tables
          where
            owner = '&OWNER'
          union all
          select
            table_name
          from
            dba_tables
          where
            temporary = 'Y'
            and owner = '&OWNER'
        )
  )
group by
  stattype_locked,
  trunc(last_analyzed),
  object_type
order by
  stattype_locked,
  last_analyzed_day,
  object_type
;

clear breaks
clear computes

undef OWNER
