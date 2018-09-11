DECLARE
  l_tablespace varchar2(30) := 'TEST';
  l_owner varchar2(30) := 'FREEK';
  l_str varchar2(32000);
BEGIN
  for r_tab in
    ( select distinct owner, table_name
      from dba_lobs
      where owner = l_owner
    )
    loop
      l_str := 'alter table "' || r_tab.owner || '"."' || r_tab.table_name || '" move ';
      for r_lob in
        ( select column_name
          from dba_lobs
          where owner = r_tab.owner
                and table_name = r_tab.table_name
        )
      loop
        l_str := l_str || 'lob("' || r_lob.column_name || '") store as (tablespace "' || l_tablespace || '") '  ;
      end loop;
    l_str := l_str || ' tablespace "' || l_tablespace || '"';
    dbms_output.put_line('moving table ' || r_tab.table_name);
    execute immediate l_str;
    for r_ind in
      ( select index_name
        from dba_indexes
        where owner = r_tab.owner
              and table_name = r_tab.table_name
              and ( tablespace_name != l_tablespace
                    or status = 'UNUSABLE'
                  )
      )
    loop
      l_str := 'alter index "' || r_tab.owner || '"."' || r_ind.index_name || '" rebuild tablespace "' || l_tablespace || '"';
      dbms_output.put_line('rebuilding index ' || r_ind.index_name || ' for table ' || r_tab.table_name);
      execute immediate l_str;
      dbms_output.put_line(l_str);
    end loop;
  end loop;
END;
/
