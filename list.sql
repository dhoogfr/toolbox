-- list all files which names containing the passed string and ending in .sql, found in the current directory
-- or in the directories found in the $SQLPATH environment variable
-- the optional second parameter determines how many subdirectories will be searched and defaults to 1 (only the directories itself)

set termout off
set verify off

-- check if a second parameter has been passed to define te depth of the search
column 2 new_value 2

select '' "2" from dual where rownum = 0;
define ldepth = '&2'

set termout on


-- actual search, if no depth has been given, the depth is set to 1
!depth=&ldepth; for i in `echo ./ ${ORACLE_PATH:-${SQLPATH}} | tr ':' ' '`; do echo ; echo $i; echo ; cd $i ; find ./ -maxdepth "${depth:-1}" -iname "*&1*.sql" -printf "   * %P\n" 2> /dev/null; done


-- cleanup
undefine 1
undefine 2
