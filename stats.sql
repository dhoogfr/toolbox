set echo on
drop table t;
create table t (x int primary key, y int);
insert into t values(1,1);
commit;
BEGIN
dbms_stats.gather_schema_stats('TEST', NULL, FALSE, 'FOR ALL INDEXED COLUMNS', NULL, 'DEFAULT', TRUE);
END;
/
select count(*) from user_tables where num_rows is not null;
select count(*) from user_indexes where num_rows is not null;
select count(distinct column_name) from user_tab_histograms;
