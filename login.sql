-- suppress the output to the screen
set termout off

REM set the editor
define_editor=vi

REM set general options
set serveroutput on size 1000000 format wrapped
set trimspool on
set tab off
set long 5000
set linesize 250
set pagesize 50000

REM used by trusted oracle
column rowlabel format a15

REM used for the show errors command
column line/col format a8
column error    format a65  word_wrapped

REM used for the show sga command
column name_col_plus_show_sga format a24

REM defaults for show parameters
column name_col_plus_show_param format a36 heading name
column value_col_plus_show_param format a30 heading value

REM defaults for set autotrace explain report
column id_plus_exp format 990 heading i
column parent_id_plus_exp format 990 heading p
column plan_plus_exp format a100
column object_node_plus_exp format a8
column other_tag_plus_exp format a29
column other_plus_exp format a44

REM commonly querried columns
column object_name format a30
column segment_name format a30
column file_name format a40
column name format a30
column file_name format a30
column what format a30 word_wrapped
column host_name format a30
column owner format a30
column table_name format a30
column index_name format a30
column column_name format a30

REM set the nls settings
alter session set nls_numeric_characters=',.';

REM set timing off
set timing off

REM set the sqlprompt
define gname=idle
column global_name new_value gname

select lower(user) || '@' ||
       substr(global_name, 1, decode(dot, 0,length(global_name), dot -1)) global_name
from ( select global_name, instr(global_name, '.') dot
       from global_name );

set sqlprompt '&gname> '

REM let sqlplus print to the screen again
set termout on

REM column my_prompt new_value myprompt
REM set termout off
REM define myprompt = 'sql> '
REM select lower(user) || '@&_connect_identifier> ' my_prompt from dual;
REM set sqlprompt '&myprompt'
select instance_name, host_name, status, (case database_role when 'PRIMARY' then database_role else database_role || ' (PRIM: ' || primary_db_unique_name || ')' end) role
from v$instance, v$database;

