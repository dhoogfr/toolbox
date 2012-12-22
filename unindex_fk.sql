column columns format a30 word_wrapped
column owner format a20
column r_owner format a20

select
    owner,
    table_name,
    constraint_name, 
    r_owner, 
    r_constraint_name,
    cname1 || nvl2(cname2,','||cname2,null) || nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) || nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) || nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null) columns
from 
    ( select
          b.owner,
          b.table_name,
          b.constraint_name,
          b.r_owner,
          b.r_constraint_name,
          max(decode( position, 1, column_name, null )) cname1,
          max(decode( position, 2, column_name, null )) cname2,
          max(decode( position, 3, column_name, null )) cname3,
          max(decode( position, 4, column_name, null )) cname4,
          max(decode( position, 5, column_name, null )) cname5,
          max(decode( position, 6, column_name, null )) cname6,
          max(decode( position, 7, column_name, null )) cname7,
          max(decode( position, 8, column_name, null )) cname8,
          count(*) col_cnt
      from dba_cons_columns a,
          dba_constraints b
      where
          a.owner = B.owner
          and a.constraint_name = b.constraint_name
          and b.constraint_type = 'R'
          and b.owner not in ('SYS', 'SYSTEM', 'MDSYS','SYSMAN', 'EXFSYS', 'DBSNMP', 'ORDDATA')
      group by b.owner, b.table_name, b.constraint_name, b.r_owner, b.r_constraint_name
    ) cons
where
    col_cnt > ALL ( select
                        count(*)
                    from
                        dba_ind_columns i
                    where
                        i.table_owner = cons.owner
                        and i.table_name = cons.table_name
                        and i.column_name in 
                            ( cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
                        and i.column_position <= cons.col_cnt
                    group by i.index_name
                  )
order by owner, table_name, constraint_name
;
