create table t1 as
with generator as 
   ( select  --+ materialize
           rownum id, substr(dbms_random.string('U',4),1,4) sortcode
     from all_objects
     where rownum <= 5000
   )
select /*+ ordered use_nl(v2) */ substr(v2.sortcode,1,4) || substr(v1.sortcode,1,2) sortcode
from generator v1, generator v2
where rownum <= 10 * 1048576;
