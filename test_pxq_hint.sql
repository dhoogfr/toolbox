-- this should cause queueing, but the hinted statements in test_pxq_hint2.sql should jump the queue
alter system set "_parallel_statement_queuing"=true;
alter system set parallel_force_local=true;
alter system set parallel_servers_target=32;                            
!ss.sh test_pxq_hint1.sql 10 kso/kso 
!ss.sh test_pxq_hint2.sql 2 kso/kso 
-- select /*+ parallel (a 16) */ avg(pk_col) from kso.skew a where col1 > 0;
-- select /*+ NO_STMT_QUEUING parallel (a 16) */ avg(pk_col) from kso.skew a where col1 > 0; 
