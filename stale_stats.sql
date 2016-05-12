drop table t;
create table t (x int primary key, y int);
insert into t(x, y) values (1,1);
commit;
alter table t monitoring;
analyze table t compute statistics;
insert into t(x) select rownum + 1 from all_objects;
commit;

DECLARE

    l_objlist       dbms_stats.objecttab;
    
BEGIN

    dbms_stats.gather_schema_Stats
    (
        ownname         => USER,
        options         => 'LIST STALE',
        objlist         => l_objlist
    );
    dbms_output.put_line('going to output all stale objects: ');
    for i in 1 .. l_objlist.count loop
        dbms_output.put_line('objtype ' || i || ': ' || l_objlist(i).objtype);
        dbms_output.put_line('objname ' || i || ': ' || l_objlist(i).objname);
    end loop;
    
END;
/
