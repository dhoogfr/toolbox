column curr_undo_span format a30 heading "Flasback Query Possible Until"

select
  to_char(systimestamp - numtodsinterval (min(tuned_undoretention), 'second'), 'DD/MM/YYYY HH24:MI:SS TZR') curr_undo_span
from
  ( select
      inst_id,
      tuned_undoretention,
      row_number() over
        ( partition by inst_id
          order by begin_time desc
        ) as rn
    from
      gv$undostat
  )
where
  rn = 1
order by
  inst_id
;
