set heading off
set feedback off
set linesize 1000
set trimspool on
set verify off
set termout off
set embedded on
set long 50000

column column_name format a1000
column text format a1000

spool &1..sql
prompt create or replace view &1 (
select decode(column_id,1,'',',') || column_name  column_name
  from user_tab_columns
 where table_name = upper('&1')
 order by column_id
/
prompt ) as
select text
  from user_views
 where view_name = upper('&1')
/
prompt /
spool off

set heading on
set feedback on
set verify on
set termout on