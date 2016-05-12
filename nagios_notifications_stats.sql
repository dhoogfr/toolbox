column client format a30
set linesize 140

break on year skip 2 on weeknr skip 1 on weekrank on weeksum

with weekdays 
as ( select 'monday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY'), 'D') daynbr
     from dual
     union all
     select 'tuesday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 1, 'D') daynbr
     from dual
     union all
     select 'wednesday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 2, 'D') daynbr
     from dual
     union all
     select 'thursday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 3, 'D') daynbr
     from dual
     union all
     select 'friday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 4, 'D') daynbr
     from dual
     union all
     select 'saturday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 5, 'D') daynbr
     from dual
     union all
     select 'sunday' day, to_char(to_date('12/11/2007', 'DD/MM/YYYY') + 6, 'D') daynbr
     from dual
),
csn
as ( select substr(servicename, 1, instr(servicename, '-', 1, 1) - 1) client,
            hostname, date_time, to_number(to_char(date_time, 'yyyy')) year,
            case when to_char(date_time, 'D') in ( select daynbr from weekdays where day in ('monday', 'tuesday'))
                    then to_number(to_char(date_time, 'iw')) -1
                 when to_char(date_time, 'D') = (select daynbr from weekdays where day = 'wednesday')
                      and date_time between trunc(date_time) and trunc(date_time) + 8/21
                    then to_number(to_char(date_time, 'iw')) -1
                 else to_number(to_char(date_time, 'iw'))
            end weeknr
     from service_notifications
     where hostname like 'dba-standby-no%'
           and date_time between add_months(sysdate, -2)
                                 and sysdate
--           and message != 'Passive service check missing.'
   )
select year, weeknr,
        dense_rank ()
            over ( order by weeksum
                 ) weekrank, 
        weeksum, 
        row_number() 
            over ( partition by year, weeknr
                   order by aantal desc, client
                 ) client_rank_per_week,
        client, aantal
from ( select csn.year, csn.weeknr, client, count(*) aantal, weeksum
       from csn,
            ( select year, weeknr, count(*) weeksum
              from csn
              group by year, weeknr
            ) counts
       where counts.year = csn.year
             and counts.weeknr = csn.weeknr
             and csn.client in
                 ( select client
                   from ( select client, count(*) counted
                          from csn
                          group by client
                          order by counted desc
                        )
                   where rownum <= 10
                 )
       group by csn.year, csn.weeknr, csn.client, counts.weeksum
     )
order by year desc, weeknr desc, aantal desc, client;