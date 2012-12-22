create or replace type obj_cols_as_rows as object 
    ( rnum          number,
      cname         varchar2(30),
      val           varchar2(4000)
    )
/

create or replace type tab_cols_as_rows
as table of obj_cols_as_rows
/

create or replace
function cols_as_rows
    ( p_query       in  varchar2
    ) RETURN tab_cols_as_rows
    
    AUTHID CURRENT_USER
    PIPELINED
    
AS

    l_theCursor         integer default dbms_sql.open_cursor;
    l_columnValue       varchar2(4000);
    l_status            integer;
    l_colCnt            number default 0;
    l_descTbl           dbms_sql.desc_tab;
    l_rnum              number := 1;
    
BEGIN

    dbms_sql.parse
        ( c             =>  l_theCursor,
          statement     =>  p_query,
          language_flag =>  dbms_sql.native
        );
        
    dbms_sql.describe_columns
        ( c             =>  l_theCursor,
          col_cnt       =>  l_colCnt,
          desc_t        =>  l_descTbl
        );
        
    for i in 1 .. l_colCnt loop
        dbms_sql.define_column
            ( c             =>  l_theCursor,
              position      =>  i,
              column       =>  l_columnValue,
              column_size   =>  4000
            );
    end loop;
    
    l_status := dbms_sql.execute
                    ( c     =>  l_theCursor
                    );
    while ( dbms_sql.fetch_rows
                ( c         =>  l_theCursor
                ) > 0
          )
    loop
    
        for i in 1 .. l_colCnt
        loop
            dbms_sql.column_value
                ( c         =>  l_theCursor,
                  position  =>  i,
                  value     =>  l_columnValue
                );
            pipe row ( obj_cols_as_rows 
                        ( l_rnum,
                          l_descTbl(i).col_name,
                          l_columnValue
                        )
                     );
        end loop;
        l_rnum := l_rnum + 1;
        
    end loop;
    
    dbms_sql.close_cursor
        ( c     => l_theCursor
        );
        
    return;
    
end cols_as_rows;
/
