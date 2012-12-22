-- skew2 and skew3 must be defined as PX 
select /*+ bloom join 2  use_hash (skew temp_skew) */ a.col2, sum(a.col1)
from kso.skew3 a, kso.skew2 b
where a.pk_col = b.pk_col
and b.col1 = 1
group by a.col2
/
