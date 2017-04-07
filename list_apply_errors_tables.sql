set linesize 300
set pages 50000

column error_table format a30

select
  T.*, 
  count(*) counted
from 
  ( select
      apply_name, 
      error_number, 
      substr(regexp_substr(error_message, 'in table .*'),10) error_table 
    from
      dba_apply_error
  ) T 
group by
  apply_name, 
  error_number, 
  error_table 
order by
  apply_name, 
  error_number, 
  error_table
 ;
