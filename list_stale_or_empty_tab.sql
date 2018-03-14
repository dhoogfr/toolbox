set pages 50000
set linesize 300

column owner heading "Owner" format a30
column table_name heading "Object Name" format a30
column partition_name heading "Partition|Name" format a30
column subpartition_name heading "Sub Partition|Name" format a30
column object_type heading "Object Type" format a12
column obj_created_str heading "Creation Date" format a16
column last_analyzed_str heading "Analyzed Date" format a16
column stattype_locked heading "Stats|Lock" format a5
column inserts heading "Inserts" format 999G999G999
column updates heading "Updated" format 999G999G999
column deletes heading "Deletes" format 999G999G999
column truncated heading "Trunc" format a5
column drop_segments heading "Dropped|Segments" format 9G999G999

set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6


break on owner skip 1

select
  stat.owner,
  stat.table_name,
  stat.partition_name,
  stat.subpartition_name,
  stat.object_type,
  to_char(obj.created, 'DD/MM/YYYY HH24:MI') obj_created_str,
  to_char(stat.last_analyzed, 'DD/MM/YYYY HH24:MI') last_analyzed_str,
  stat.stattype_locked,
  mod.inserts,
  mod.updates,
  mod.deletes,
  mod.truncated,
  mod.drop_segments
from
  dba_tab_statistics                          stat
    left outer join dba_tab_modifications     mod
      on ( stat.owner = mod.table_owner
           and stat.table_name = mod.table_name
           and ( stat.partition_name = mod.partition_name
                 or stat.object_type != 'PARTITION'
               )
           and ( stat.table_name = mod.table_name
                 and stat.subpartition_name = mod.subpartition_name
                 or stat.object_type != 'SUBPARTITION'
               )    
         )
    join dba_objects                          obj
      on ( stat.owner = obj.owner
           and stat.table_name = obj.object_name
           and ( nvl(stat.subpartition_name, stat.partition_name) = obj.subobject_name
                 or ( stat.partition_name is null
                      and obj.subobject_name is null
                    )
               ) 
         )
where
  ( stat.stale_stats = 'YES'
    or stat.last_analyzed is null
  )
  and stat.owner not in 
    ( 'SYS', 'SYSTEM', 'WMSYS', 'GSMADMIN_INTERNAL','ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP',
      'EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS', 'SI_INFORMTN_SCHEMA',
      'SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS'
    )
  and stat.owner like nvl('&1', '%')
  -- filter out temporary and dropped tables
  and (stat.owner, stat.table_name) not in
    ( select 
        table_owner,
        table_name
      from
        dba_tables
      where
        temporary = 'Y'
        or dropped =  'YES'
    )
order by
  stat.owner,
  stat.table_name,
  stat.partition_name nulls first,
  stat.subpartition_name nulls first
;

clear breaks

undef 1
