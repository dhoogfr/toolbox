-- generate sql to delete all asm files for a given database
column a format a120
set linesize 120
select 'alter diskgroup ' || gname || ' drop file ''+' || gname || sys_connect_by_path(aname, '/') || ''';' a
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory
       from v$asm_alias a, v$asm_diskgroup b
       where a.group_number = b.group_number
     )
where alias_directory = 'N'
      and system_created = 'Y'
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;

-- generate sql to delete all the asm files of a given type for a given database
column a format a120
set linesize 120
select 'alter diskgroup ' || gname || ' drop file ''+' || gname || sys_connect_by_path(aname, '/') || ''';' a
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
where alias_directory = 'N'
      and system_created = 'Y'
      and file_type = '&FILETYPE'
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;

-- generate sql to delete all the asm files except of a given type for a given database
column a format a120
set linesize 120
select 'alter diskgroup ' || gname || ' drop file ''+' || gname || sys_connect_by_path(aname, '/') || ''';' a
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
where alias_directory = 'N'
      and system_created = 'Y'
      and file_type != '&FILETYPE'
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;

-- generate a list of all the asm files / directories / aliasses for a given database
column full_alias_path format a75
column file_type format a15
select concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path, 
       system_created, alias_directory, file_type
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;

-- generate a list of all the asm files of a given type for a given database
column full_alias_path format a70
column file_type format a15
select concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path, 
       system_created, alias_directory, file_type
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
where alias_directory = 'N'
      and system_created = 'Y'
      and file_type = '&FILETYPE'
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;