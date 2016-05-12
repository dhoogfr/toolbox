set linesize 170
set pages 9999

select * from table(dbms_xplan.display);