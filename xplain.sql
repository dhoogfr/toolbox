set linesize 150
set pages 9999

select * from table(dbms_xplan.display);