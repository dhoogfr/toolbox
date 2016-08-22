-- list all files which names containing the passed string and ending in .sql, found in the current directory
-- or in the directories found in the $SQLPATH environment variable
-- the optional second parameter determines how many subdirectories will be searched and defaults to 1 (only the directories itself)

set termout off
set verify off

column 2 new_value 2

select '' "2" from dual where rownum = 0;
define ldepth = '&2'

set termout on


!depth=&ldepth; for i in `echo ./ $SQLPATH | tr ':' ' '`; do echo ; echo $i; echo ; cd $i ; find ./ -maxdepth "${depth:-1}" -iname "*&1*.sql"  2> /dev/null; done

undefine 2
