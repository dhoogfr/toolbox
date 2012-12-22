set linesize 150

column username format a20
column bi format 99
column bs format 9999
column siw format 999999
column rwo# format 999999
column tl format a5
column inst_id format a10

with sessions
as ( select /*+ MATERIALIZE */
            inst_id, sid, serial#, username, sql_id, blocking_instance bi, blocking_session bs, 
            seconds_in_wait siw, row_wait_obj# rwo#,  row_wait_file# rwf#, row_wait_block# rwb#,
            row_wait_row# rwr#
     from gv$session
   )
select lpad('-', level, '-') || inst_id inst_id, sid, serial#, username, sql_id, bi, bs, siw, rwo#,  
       rwf#, rwb#, rwr#
from sessions
where bs is not null
      or (inst_id, sid) in
        ( select bi, bs
          from sessions
        )
start with bs is null
connect by ( bi = prior inst_id
             and bs = prior sid
           )
;


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