set linesize 150

column username format a20
column bi format 99
column bs format 9999
column siw format 999999
column rwo# format 999999

select inst_id, sid, serial#, username, sql_id, blocking_instance bi, blocking_session bs, 
       seconds_in_wait siw, row_wait_obj# rwo#,  row_wait_file# rwf#, row_wait_block# rwb#,
       row_wait_row# rwr#
from gv$session 
where blocking_session is not null;


/*
FUNCTION ROWID_CREATE RETURNS ROWID
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ROWID_TYPE                     NUMBER                  IN
 OBJECT_NUMBER                  NUMBER                  IN
 RELATIVE_FNO                   NUMBER                  IN
 BLOCK_NUMBER                   NUMBER                  IN
 ROW_NUMBER                     NUMBER                  IN

select dbms_rowid.rowid_create(1, 81574, 26, 286, 262) from dual;
*/