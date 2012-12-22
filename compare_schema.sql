/*  
This script compares the object definitions in the current schema 
to that of a remote schema.
The remote schema is defined using a database link.
THE SCRIPT COMPARES THE FOLLOWING:
- Existence of tables
- Existence of columns
- Column definitions
- Existence of indexes
- Index definitions (column usage)
- Existence of constraints
- Constraint definitions (table, type and reference)
- Constraint column usage (for unique, primary key and foreign keys)
- Check constraint definitions
- Existence of triggers
- Definition of triggers
- Existence of procedure/packages/functions
- Definition of procedures/packages/functions
(Ie. the script does not do a complete check, it does not for example
check any grants, synonyms, clusters or storage definitions).
The script drops and creates a few temporary objects prefixed with
the first 3 letter combination (AAA - ZZZ) that does not conflict with any 
existing objects.
If you find ways of improving this script or have any comments and/or
problems, please send a mail to the author.
This script has been tested on Oracle 7.3.
*/
undef prex
undef prefx
undef a
undef thisuser
undef b
undef REMOTESCHEMA
undef REMOTEPASSW 
undef connstring 
undef c
undef todaysdate
variable prefx varchar2(3)
declare
i number ;
j number ;
k number ;
cnt number;
begin
 for i in ascii('A') .. ascii('Z') loop
  for j in ascii('A') .. ascii('Z') loop
   for k in ascii('A') .. ascii('Z') loop
     select count(*) into cnt from user_objects where object_name like
     chr(i)||chr(j)||chr(k)||'%';
     if cnt = 0 then
       :prefx := chr(i)||chr(j)||chr(k);  
       return;
     end if;
    end loop;
   end loop;
  end loop;
end;
/
column a new_val prex
set verify off
set linesize 132
set feedback off
select :prefx a from dual;
column b new_val thisuser
select user b from dual;
column c new_val todaysdate
select to_char(sysdate,'DD-MON-YYYY HH24:MI') c from dual;
accept REMOTESCHEMA char prompt 'Enter remote username:'
accept REMOTEPASSW char prompt 'Enter remote password:' hide
accept connstring char prompt 'Enter remote connectstring:'
spool dbdiff
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT     SCHEMA DEFINITION DIFFERENCES     &todaysdate        
PROMPT          
PROMPT           this schema: &thisuser  
PROMPT         remote schema: &remoteschema.@&connstring
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT
PROMPT
create database link &prex.lnk connect to &REMOTESCHEMA identified 
by &REMOTEPASSW using '&CONNSTRING';
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  TABLES MISSING IN THIS SCHEMA:
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &prex.common_tables as
select table_name from user_TAbles@&prex.lnk
intersect
select table_name from user_tables;
select table_name from user_TAbles@&prex.lnk
minus
select table_name from &prex.common_tables;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TABLES MISSING IN REMOTE SCHEMA:
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name from user_TAbles where table_name not like '&prex.%'
minus
select table_name from user_tables@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COLUMNS MISSING IN THIS SCHEMA FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from user_tab_columns@&prex.lnk
where table_name in
(select table_name from &prex.common_tables)
minus
select table_name,column_name from user_tab_columns 
where table_name in
(select table_name from &prex.common_tables);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COLUMNS MISSING IN REMOTE SCHEMA FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,column_name from user_tab_columns
where table_name in
(select table_name from &prex.common_tables)
minus
select table_name,column_name from user_tab_columns@&prex.lnk 
where table_name in
(select table_name from &prex.common_tables);

create table &prex.diff_cols1
( TABLE_NAME                   VARCHAR2(30),
 COLUMN_NAME                VARCHAR2(30),
 DATA_TYPE                      VARCHAR2(9),
 DATA_LENGTH                  NUMBER,
 DATA_PRECISION             NUMBER,
 DATA_SCALE                    NUMBER,
 NULLABLE                        VARCHAR2(1),
 COLUMN_ID                      NUMBER,
 DEFAULT_LENGTH            NUMBER,
 DATA_DEFAULT                 varchar2(2000));
create table &prex.diff_cols2
( TABLE_NAME                   VARCHAR2(30),
 COLUMN_NAME                VARCHAR2(30),
 DATA_TYPE                      VARCHAR2(9),
 DATA_LENGTH                  NUMBER,
 DATA_PRECISION             NUMBER,
 DATA_SCALE                    NUMBER,
 NULLABLE                        VARCHAR2(1),
 COLUMN_ID                      NUMBER,
 DEFAULT_LENGTH            NUMBER,
 DATA_DEFAULT                 varchar2(2000));
declare
cursor c1 is
select
 l.TABLE_NAME ,                    
 l.COLUMN_NAME,                    
 l.DATA_TYPE ,                    
 l.DATA_LENGTH,                    
 l.DATA_PRECISION ,                    
 l.DATA_SCALE ,                    
 l.NULLABLE,                    
 l.COLUMN_ID ,                    
 l.DEFAULT_LENGTH ,                    
 l.DATA_DEFAULT  
from user_tab_columns l,&prex.common_tables c
where c.table_name=l.table_name ;
TYPE rec is record (
 TABLE_NAME                   VARCHAR2(30),
 COLUMN_NAME                VARCHAR2(30),
 DATA_TYPE                      VARCHAR2(9),
 DATA_LENGTH                  NUMBER,
 DATA_PRECISION             NUMBER,
 DATA_SCALE                    NUMBER,
 NULLABLE                        VARCHAR2(1),
 COLUMN_ID                      NUMBER,
 DEFAULT_LENGTH            NUMBER,
 DATA_DEFAULT                 varchar2(2000)
);
c rec;
begin
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &prex.diff_cols1 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,
     c.DATA_PRECISION, c.DATA_SCALE, c.NULLABLE, c.COLUMN_ID, 
     c.DEFAULT_LENGTH, c.DATA_DEFAULT);
end loop;
end;
/
declare
cursor c1 is
select
 l.TABLE_NAME ,                    
 l.COLUMN_NAME,                    
 l.DATA_TYPE ,                    
 l.DATA_LENGTH,                    
 l.DATA_PRECISION ,                    
 l.DATA_SCALE ,                    
 l.NULLABLE,                    
 l.COLUMN_ID ,                    
 l.DEFAULT_LENGTH ,                    
 l.DATA_DEFAULT  
from user_tab_columns@&prex.lnk l,&prex.common_tables c
where c.table_name=l.table_name ;
TYPE rec is record (
 TABLE_NAME                   VARCHAR2(30),
 COLUMN_NAME                VARCHAR2(30),
 DATA_TYPE                      VARCHAR2(9),
 DATA_LENGTH                  NUMBER,
 DATA_PRECISION             NUMBER,
 DATA_SCALE                    NUMBER,
 NULLABLE                        VARCHAR2(1),
 COLUMN_ID                      NUMBER,
 DEFAULT_LENGTH            NUMBER,
 DATA_DEFAULT                 varchar2(2000)
);
c rec;
begin
 open c1;
 loop
   fetch c1 into c;
    exit when c1%NOTFOUND;
    insert into &prex.diff_cols2 values 
    (c.table_name,c.column_name,c.data_type,c.data_length,
     c.DATA_PRECISION, c.DATA_SCALE, c.NULLABLE, c.COLUMN_ID, 
     c.DEFAULT_LENGTH, c.DATA_DEFAULT);
end loop;
end;
/
column table_name format a20
column column_name format a20
column param format a15
column local_value format a20
column remote_value format a20
set arraysize 1
set maxdata 32000
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT DIFFERENCE IN COLUMN-DEFS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select l.table_name,l.column_name,'DATA_DEFAULT' param ,
l.DATA_DEFAULT local_value, r.DATA_DEFAULT remote_value
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.DATA_DEFAULT != r.DATA_DEFAULT
union
select l.table_name,l.column_name,'DATA_TYPE',l.data_type,r.data_type 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.data_type != r.data_type
union
select l.table_name,l.column_name,'DATA_LENGTH',to_char(l.data_length),
to_char(r.data_length) 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.data_length != r.data_length
union
select l.table_name,l.column_name,'DATA_PRECISION',
to_char(l.DATA_PRECISION),to_char(r.DATA_PRECISION) 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.DATA_PRECISION != r.DATA_PRECISION
union
select l.table_name,l.column_name,'DATA_SCALE',to_char(l.DATA_SCALE),
to_char(r.DATA_SCALE) 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.DATA_SCALE != r.DATA_SCALE
union
select l.table_name,l.column_name,'NULLABLE',l.NULLABLE,r.NULLABLE 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.NULLABLE != r.NULLABLE
union
select l.table_name,l.column_name,'COLUMN_ID',to_char(l.COLUMN_ID),
to_char(r.COLUMN_ID) 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.COLUMN_ID != r.COLUMN_ID
union
select l.table_name,l.column_name,'DEFAULT_LENGTH',to_char(l.DEFAULT_LENGTH),
to_char(r.DEFAULT_LENGTH) 
from &prex.diff_cols1 l, &prex.diff_cols2 r 
where l.table_name=r.table_name and 
      l.column_name=r.column_name and l.DEFAULT_LENGTH != r.DEFAULT_LENGTH
order by 1,2
/                
         
create table &prex.common_indexes as
select table_name, index_name from user_indexes@&prex.lnk
where table_name in (select table_name from &prex.common_tables)
intersect
select table_name, INdex_name from user_indexes
where table_name in (select table_name from &prex.common_tables);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEXES MISSING IN THIS SCHEMA FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name, index_name from user_indexes@&prex.lnk
where table_name in (select table_name from &prex.common_tables)
minus
select table_name, index_name from &prex.common_indexes;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEXES MISSING IN REMOTE SCHEMA FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name, index_name from user_indexes
where table_name in (select table_name from &prex.common_tables)
minus
select table_name, index_name from &prex.common_indexes;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON INDEXES WITH DIFFERENT UNIQUENESS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.table_name, a.index_name, a.uniqueness local, b.uniqueness remote
from user_indexes a,
         user_indexes@&prex.lnk b
where  a.index_name = b.index_name
and   a.uniqueness != b.uniqueness
and  (a.table_name, a.index_name) in
(select table_name, index_name from &prex.common_indexes);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS MISSING IN THIS SCHEMA FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from user_ind_columns@&prex.lnk
where (table_name,index_name)  in 
(select table_name,index_name from &prex.common_indexes)
minus
select index_name, column_name from user_ind_columns
where (table_name,index_name)  in 
(select table_name,index_name from &prex.common_indexes);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS MISSING IN REMOTE  SCHEMA FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select index_name, column_name from user_ind_columns
where (table_name,index_name)  in 
(select table_name,index_name from &prex.common_indexes)
minus
select index_name, column_name from user_ind_columns@&prex.lnk
where (table_name,index_name)  in 
(select table_name,index_name from &prex.common_indexes);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT INDEX COLUMNS POSITIONED DIFFERENTLY FOR COMMON INDEXES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.index_name, a.column_name, a.column_position local,
           b.column_position remote
           from user_ind_columns a,
                        user_ind_columns@&prex.lnk b
where  (a.table_name,a.index_name) in 
(select table_name,index_name from &prex.common_indexes) 
and b.index_name = a.index_name
and b.table_name = a.table_name
and a.column_name = b.column_name
and a.column_position != b.column_position;
 
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT CONSTRAINTS MISSING IN THIS SCHEMA FOR COMMON TABLES
PROMPT (WORKS ONLY FOR CONSTRAINT WITH NON SYSTEM GENERATED NAMES)
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from user_constraints@&prex.lnk
where constraint_name not like 'SYS%' and table_name in
(select table_name from &prex.common_tables)
minus
select table_name,constraint_name from user_constraints 
where constraint_name not like 'SYS%' and table_name in
(select table_name from &prex.common_tables);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT CONSTRAINTS MISSING IN REMOTE SCHEMA FOR COMMON TABLES
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select table_name,constraint_name from user_constraints
where constraint_name not like 'SYS%' and table_name in
(select table_name from &prex.common_tables)
minus
select table_name,constraint_name from user_constraints@&prex.lnk 
where constraint_name not like 'SYS%' and table_name in
(select table_name from &prex.common_tables);
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON CONSTRAINTS, TYPE MISMATCH
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.constraint_type local_type, 
b.constraint_type remote_type
from user_constraints a, user_constraints@&prex.lnk b where
a.table_name = b.table_name and
a.constraint_name=b.constraint_name and 
a.constraint_type !=b.constraint_type;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT COMMON CONSTRAINTS, TABLE MISMATCH
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select a.constraint_name,a.table_name,b.table_name from
user_constraints a, user_constraints@&prex.lnk b,
(select z.constraint_name from 
(select constraint_name, table_name from useR_constraints union
select constraint_name, table_name from user_constraints@&prex.lnk) z
group by constraint_name having count(*) >1) q
where a.constraint_name = q.constraint_name and 
b.constraint_name=q.constraint_name
and a.table_name != b.table_name;
create table &prex.comcons as
select constraint_name, constraint_type, table_name 
from useR_constraints 
intersect 
select constraint_name, constraint_type, table_name 
from user_constraints@&prex.lnk;
delete from &prex.comcons where constraint_name in 
(select constraint_name from &prex.comcons 
group by constraint_name having count(*) > 1);
delete from &prex.comcons where constraint_name like 'SYS%';
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  DIFFERENCES IN COLUMN USAGE FOR CONSTRAINT DEFS 
PROMPT    (Unique key, Primary Key, Foreign key)
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declare
cursor c1 is
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from user_cons_columns a, &prex.comcons b
where a.constraint_name=b.constraint_name
union
select a.constraint_name,a.position,a.column_name,b.constraint_type 
from user_cons_columns@&prex.lnk a, &prex.comcons b
where a.constraint_name=b.constraint_name
minus
(select a.constraint_name,a.position,a.column_name,b.constraint_type 
   from user_cons_columns a, &prex.comcons b
   where a.constraint_name=b.constraint_name
intersect
select a.constraint_name,a.position,a.column_name,b.constraint_type 
  from user_cons_columns@&prex.lnk a, &prex.comcons b
  where a.constraint_name=b.constraint_name
);
i binary_integer;
begin
for c in c1 loop
   dbms_output.put_line('COLUMN USAGE DIFFERENCE FOR '||c.constraint_type||
            ' CONSTRAINT '||c.constraint_name);
   dbms_output.put_line('. Local columns:');
   i:=1;
   for c2 in (select column_name col 
             from user_cons_columns 
             where constraint_name=c.constraint_name order by position) 
   loop
      dbms_output.put_line('.   '||c2.col);
  end loop;
   i:=1;
   dbms_output.put_line('. Remote columns:');
   for c3 in (select column_name col 
             from user_cons_columns@&prex.lnk 
             where constraint_name=c.constraint_name 
             ) 
   loop
      dbms_output.put_line('.   '||c3.col);
  end loop;
end loop;
end;
/
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT DIFFERENCES IN CHECK CONSTRAINT DEFS 
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set serveroutput on
declare 
cursor c1 is select constraint_name,constraint_type,table_name 
from &prex.comcons where constraint_type='C';
cons varchar2(50);
tab1 varchar2(50);
tab2 varchar2(50);
search1 varchar2(32000);
search2 varchar2(32000);
begin
dbms_output.enable(100000);
for c in c1 loop
  select search_condition into search1 from user_constraints 
   where constraint_name=c.constraint_name;
  select search_condition into search2 from user_constraints@&prex.lnk 
   where constraint_name=c.constraint_name;
  if search1 != search2 then
   dbms_output.put_line('Check constraint '||c.constraint_name||
                        ' defined differently!');
   dbms_output.put_line('. Local definition:');
   dbms_output.put_line('.  '||search1);
   dbms_output.put_line('. Remote definition:');
   dbms_output.put_line('.  '||search2);
  end if;
end loop;
end;
/
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGERS MISSING IN REMOTE SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from user_Triggers minus 
select trigger_name from user_Triggers@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGERS MISSING IN THIS SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select trigger_name from user_Triggers minus 
select trigger_name from user_Triggers@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT TRIGGER DEFINITION DIFFERENCES ON COMMON TRIGGERS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set serveroutput on
declare
cursor c1 is select 
TRIGGER_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,
TABLE_NAME,REFERENCING_NAMES,rtrim(WHEN_CLAUSE,' '),STATUS,                 
rtrim(replace(description,'"&thisuser".',null),' ') DESCRIPTION,
TRIGGER_BODY from user_Triggers;
nam1 varchar2(30);
type1 varchar2(16);
event1 varchar2(26);
table1 varchar2(30);
ref1 varchar2(87);
when1 varchar2(2000);
status1 varchar2(8);
desc1 varchar2(2000);
body1 varchar2(32000);
type2 varchar2(16);
event2 varchar2(26);
table2 varchar2(30);
ref2 varchar2(87);
when2 varchar2(2000);
status2 varchar2(8);
desc2 varchar2(2000);
body2 varchar2(32000);
pr_head boolean;
begin
dbms_output.enable(100000);
open c1;
loop
 fetch c1 into nam1,type1,event1,table1,ref1,when1,status1,desc1,body1;
 exit when c1%notfound;
 begin
  select 
  TRIGGER_TYPE,TRIGGERING_EVENT,
  TABLE_NAME,REFERENCING_NAMES,rtrim(WHEN_CLAUSE,' '),STATUS,                 
  rtrim(replace(description,upper('"&remoteschema".'),null),' ') DESCRIPTION,
  TRIGGER_BODY 
  into type2,event2,table2,ref2,when2,status2,desc2,body2 
  from user_Triggers@&prex.lnk
  where trigger_name=nam1;
  pr_head := FALSE;
  if table1 != table2 then
    dbms_output.put_line('T R I G G E R : '||nam1);
    dbms_output.put_line('-------------------------------------------------'||
                         '-----------------------');
    pr_head := TRUE;
    dbms_output.put_line('   ');
    dbms_output.put_line('DEFINED ON DIFFERENT TABLES!');
    dbms_output.put_line('.   This table_name  : '||table1);
    dbms_output.put_line('.   Remote table_name: '||table2);
  end if;
  if event1 != event2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DEFINED FOR DIFFERENT EVENTS!');
    dbms_output.put_line('.   This event: '||event1);
    dbms_output.put_line('. Remote event: '||event2);
  end if;
  if type1 != type2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT TYPES!');
    dbms_output.put_line('.   This type: '||type1);
    dbms_output.put_line('.      Remote: '||type2);
  end if;
  if ref1 != ref2 then
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT REFERENCES!');
    dbms_output.put_line('.   This ref: '||ref1);
    dbms_output.put_line('.     Remote: '||ref2);
  end if;
    if when1 != when2 then
    dbms_output.put_line('   ');
    if not pr_head then
     dbms_output.put_line('T R I G G E R : '||nam1);
     dbms_output.put_line('-------------------------------------------------'||
                          '-----------------------');
     pr_head := TRUE;
    end if;
    dbms_output.put_line('DIFFERENT WHEN CLAUSES!');
    dbms_output.put_line('.  Local when_clause:');
    dbms_output.put_line(when1);
    dbms_output.put_line('.  Remote when_clause: ');
    dbms_output.put_line(when2);
  end if;
  if status1 != status2 then
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT STATUS!');
    dbms_output.put_line('.  Local status: '||status1);
    dbms_output.put_line('.  Remote status: '||status2);
  end if;
 if replace(desc1,chr(10),'') != replace(desc2,chr(10),'') then
    dbms_output.put_line('   ');
    dbms_output.put_line('DIFFERENT DESCRIPTIONS!');
    dbms_output.put_line('Local definition: ');
    dbms_output.put_line(desc1);
    dbms_output.put_line('Remote definition: ');
    dbms_output.put_line(desc2);
  end if;
  if body1 != body2 then
    dbms_output.put_line('   ');
    dbms_output.put_line('THE PL/SQL BLOCKS ARE DIFFERENT! ');
    dbms_output.put_line('   ');
  end if;
  exception when NO_DATA_FOUND then null;
  when others then raise_application_error(-20010,SQLERRM);
 end;
end loop;
end;
/
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT MISSING PROCEDURES/PACKAGES/FUNCTIONS IN REMOTE SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct name,type from user_source minus 
select distinct name,type from user_source@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT MISSING PROCEDURES/PACKAGES/FUNCTIONS IN LOCAL SCHEMA
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct name,type from user_source@&prex.lnk minus 
select distinct name,type from user_source;
create table &prex.comcod as
select distinct name,type from user_source intersect 
select distinct name,type from user_source@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT PROCEDURES/PACKAGES/FUNCTIONS WITH DIFFERENT DEFINITIONS
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct q.name Object_name,q.type Object_type from 
(select a.name,a.type,a.line,a.text 
   from user_source a, &prex.comcod b 
  where a.name=b.name union 
select a.name,a.type,a.line,a.text 
 from user_source@&prex.lnk a, &prex.comcod b 
where a.name=b.name 
minus
(select a.name,a.type,a.line,a.text 
   from user_source a, &prex.comcod b 
  where a.name=b.name 
 intersect
select a.name,a.type,a.line,a.text 
  from user_source@&prex.lnk a, &prex.comcod b 
 where a.name=b.name )) q;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT  VIEWS MISSING IN THIS SCHEMA:
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create table &prex.common_views as
select view_name from user_views@&prex.lnk
intersect
select view_name from user_views;
select view_name from user_views@&prex.lnk
minus
select view_name from &prex.common_views;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT VIEWS MISSING IN REMOTE SCHEMA:
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select view_name from user_views
minus
select view_name from user_views@&prex.lnk;
PROMPT
PROMPT
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT VIEWS WITH DIFFERENCES IN THE DEFINITION
PROMPT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declare
def1 varchar2(32000);
def2 varchar2(32000);
len1 number;
len2 number;
i number;
cursor c1 is select view_name from &prex.common_views;
begin
dbms_output.enable(100000);
for c in c1 loop
  select text,text_length into def1,len1
          from user_Views where view_name=c.view_name;
  select text,text_length into def2,len2
      from user_Views@&prex.lnk where view_name=c.view_name;
        i := 1;
  def1:=replace(def1,' ','');
  def2:=replace(def2,' ','');
  if def1 != def2 or length(def1) != length(def2) then
    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
    dbms_output.put_line('|  '||c.view_name ||
                         '                               |');
    dbms_output.put_line(lpad('-',35+length(c.view_name),'-'));
        dbms_output.put_line('Local text_length:   ' || to_char(len1));
        dbms_output.put_line('Remote text_length):  ' || to_char(len2));
    dbms_output.put_line(' ');
        i := 1;
        while i <= length(def1) loop
           if substr(def1,i,240) != substr(def2,i,240) then
                   dbms_output.put_line('Difference at offset ' || to_char(i)
);
                   dbms_output.put_line('   local:   ' || substr(def1,i,240));
                   dbms_output.put_line('   remote:  ' || substr(def2,i,240));
       end if;
           i := i + 240;
    end loop;
  end if;
  if length(def2) > length(def1) then
         dbms_output.put_line('Remote longer than Local. Next 255 bytes:    ');
         dbms_output.put_line(substr(def2,length(def1),255));
  end if;
end loop;
end;
/
drop database link &prex.lnk;
drop table &prex.comcod;
drop table &prex.diff_cols1;
drop table &prex.diff_cols2;
drop table &prex.common_tables;
drop table &prex.common_views;
drop table &prex.ind;
drop table &prex.ind1;
drop table &prex.ind2;
drop table &prex.comcons;
spool off
set verify on
set feedback on
undef prex
undef prefx
undef a
undef thisuser
undef b
undef REMOTESCHEMA
undef REMOTEPASSW 
undef connstring 
undef c
undef todaysdate

