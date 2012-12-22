set linesize 130
set pages 999

column datum format a10
column client format a15
column tijd format a5
column bericht format a90 word_wrapped

select to_char(date_time, 'DD/MM/YYYY') datum, client, to_char(date_time, 'HH24:MI') tijd, trim(checkname) || ': ' || trim(message) bericht
from notifications
where weeknr = &weeknr
      and year = &year
order by date_time;