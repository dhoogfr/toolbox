select
    sid,
    serial#,
    opname,
    sofar,
    totalwork,
    ((100/totalwork) * sofar) as percentage_complete,
    to_char(start_time, 'dd/mm/yyyy hh24:mi:ss') as start_time,
    to_char(last_update_time, 'dd/mm/yyyy hh24:mi:ss') as last_update_time,
    time_remaining,
    elapsed_seconds,
--    trunc( mod( (time_remaining / 60 / 60),60 ))  || ':' || trunc( mod( (time_remaining) / 60, 60 ) ) || ':' || trunc( mod( time_remaining, 60 ) ),
    message,
    sql_address,
    sql_hash_value
from
    v$session_longops
where
    time_remaining > 0;
