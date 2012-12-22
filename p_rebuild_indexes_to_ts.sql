create or replace procedure
       p_rebuild_indexes_to_ts (schema IN      dba_extents.owner%type,
 ts_name       IN              dba_tablespaces.tablespace_name%type)
       as
               v_cursorid              integer;
               status                  integer;
               cursor c_dba_extents is
                       select owner,segment_name,
                       tablespace_name,count(*)
                       from dba_extents
                       where owner=upper(schema)
                       and segment_type='INDEX'
                       group by owner,segment_name,tablespace_name;
               v_dba_extents           c_dba_extents%rowtype;
               begin
                       open c_dba_extents;
                       v_cursorid:=dbms_sql.open_cursor;
                       fetch c_dba_extents into v_dba_extents;
                       if (c_dba_extents%notfound) then
                               dbms_output.put_line('Owner '||
                               upper(schema)||' : '||
                               'Noindexes were to be found for this user.');
                       end if;         
                       while ( c_dba_extents%found ) loop
                               dbms_sql.parse(v_cursorid,
                               'ALTER INDEX '||v_dba_extents.owner||'.'||
                               v_dba_extents.segment_name||
                               '  REBUILD TABLESPACE     '||ts_name,
                               dbms_sql.native);
                               status:=dbms_sql.execute(v_cursorid);
                               dbms_output.put_line('Index Rebuild: '||
                               v_dba_extents.owner||'.'||
                               v_dba_extents.segment_name||'  '||ts_name);
                               fetch c_dba_extents into v_dba_extents; 
               end loop;
               close c_dba_extents;
               dbms_sql.close_cursor(v_cursorid);
               exception
                       when others then
                               dbms_output.put_line('Error...... ');   
                               dbms_sql.close_cursor(v_cursorid);
                               raise;
       end p_rebuild_indexes_to_ts;
/
