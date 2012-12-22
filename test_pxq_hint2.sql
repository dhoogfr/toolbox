select /*+ NO_STATEMENT_QUEUING parallel (a 16) */ avg(pk_col) from kso.skew3 a where col1 > 0; 
