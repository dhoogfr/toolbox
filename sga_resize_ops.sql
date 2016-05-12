set linesize 140
set pages 9999

column initial_mb format 9G999D99
column target_mb format 9G999D99
column final_mb format 9G999D99
column component format a30

select *
from  ( select to_char(start_time, 'DD/MM/YYYY HH24:MI:SS') start_time, to_char(end_time, 'DD/MM/YYYY HH24:MI:SS') end_time, 
               component, oper_type, oper_mode, initial_size/1024/1024 initial_mb, target_size/1024/1024 target_mb, 
               final_size/1024/1024 final_mb, status
        from v$sga_resize_ops a
        order by a.start_time desc
      )
where rownum <= 40;