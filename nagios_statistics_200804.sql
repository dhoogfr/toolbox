column counted format 9G999G999

select to_number(to_char(senddate, 'YYYY')) year, to_number(to_char(senddate, 'WW')) week, count(*) counted
from stats_200804
where notification_group in
        ( 'bvp-sms', 'bvp-sms-bus', 'bvp-sms-nonbus', 'dba-standby-bus', 'dba-standby-nonbus',
          'dba-standby-nonbus-nowarn', 'hosting-standby-bus', 'hosting-standby-nonbus',
          'janssst-sms-nonbus', 'liekejo-sms-bus', 'liekejo-sms-nonbus', 'network-standby-bus',
          'network-standby-nonbus', 'spruyma-bus-sms', 'spruyma-nonbus-sms', 'spruyma-standby-bus',
          'spruyma-standby-nonbus', 'vanropi-bus-sms', 'vanropi-nonbus-sms', 'vermema-sms-nonbus', 
          'win-standby-bus', 'win-standby-nonbus'
        )
      and senddate >= add_months(trunc(sysdate, 'MM'), -6)
group by to_number(to_char(senddate, 'YYYY')), to_number(to_char(senddate, 'WW'))
order by year, week;



set linesize 120
set pages 9999

column counted format 9G999G999
column notification_group format a50
break on begin_date skip 1 on end_date
compute sum of counted on begin_date

select trunc(senddate, 'MM') begin_date, add_months(trunc(senddate, 'MM'), 1) - 1 end_date, notification_group, count(*) counted
from stats_200804
where notification_group in
        ( 'bvp-sms', 'bvp-sms-bus', 'bvp-sms-nonbus', 'dba-standby-bus', 'dba-standby-nonbus',
          'dba-standby-nonbus-nowarn', 'hosting-standby-bus', 'hosting-standby-nonbus',
          'janssst-sms-nonbus', 'liekejo-sms-bus', 'liekejo-sms-nonbus', 'network-standby-bus',
          'network-standby-nonbus', 'spruyma-bus-sms', 'spruyma-nonbus-sms', 'spruyma-standby-bus',
          'spruyma-standby-nonbus', 'vanropi-bus-sms', 'vanropi-nonbus-sms', 'vermema-sms-nonbus', 
          'win-standby-bus', 'win-standby-nonbus'
        )
      and senddate >= add_months(trunc(sysdate, 'MM'), -6)
group by notification_group, trunc(senddate, 'MM')
order by begin_date, notification_group;







set linesize 120
set pages 9999

column counted format 9G999G999
column month_sum format 9G999G999
column pct format 990D99
column notification_group format a50
break on begin_date skip 1 on end_date skip 1
compute sum of counted on begin_date

select sendmonth begin_date, add_months(sendmonth, 1) - 1 end_date, ranking, notification_group, counted, month_sum,
       (100/month_sum) * counted pct
from ( select sendmonth, notification_group, counted,
              dense_rank () over ( partition by sendmonth order by counted desc) ranking,
              sum(counted) over (partition by sendmonth) month_sum
       from ( select trunc(senddate, 'MM') sendmonth, notification_group, count(*) counted
              from stats_200804
              where notification_group in
                      ( 'bvp-sms', 'bvp-sms-bus', 'bvp-sms-nonbus', 'dba-standby-bus', 'dba-standby-nonbus',
                        'dba-standby-nonbus-nowarn', 'hosting-standby-bus', 'hosting-standby-nonbus',
                        'janssst-sms-nonbus', 'liekejo-sms-bus', 'liekejo-sms-nonbus', 'network-standby-bus',
                        'network-standby-nonbus', 'spruyma-bus-sms', 'spruyma-nonbus-sms', 'spruyma-standby-bus',
                        'spruyma-standby-nonbus', 'vanropi-bus-sms', 'vanropi-nonbus-sms', 'vermema-sms-nonbus', 
                        'win-standby-bus', 'win-standby-nonbus'
                      )
                    and senddate >= add_months(trunc(sysdate, 'MM'), -6)
              group by notification_group, trunc(senddate, 'MM')
            )
     )
where ranking <= 10
order by sendmonth, ranking, notification_group;




set linesize 120
set pages 9999

column counted format 9G999G999
column month_sum format 9G999G999
column pct format 990D99
column clientname format a30
break on begin_date skip 1 on end_date skip 1
compute sum of counted on begin_date

select sendmonth begin_date, add_months(sendmonth, 1) - 1 end_date, ranking, clientname, counted, month_sum,
       (100/month_sum) * counted pct
from ( select sendmonth, clientname, counted,
              dense_rank () over ( partition by sendmonth order by counted desc) ranking,
              sum(counted) over (partition by sendmonth) month_sum
       from ( select trunc(senddate, 'MM') sendmonth, clientname, count(*) counted
              from stats_200804
              where notification_group in
                      ( 'bvp-sms', 'bvp-sms-bus', 'bvp-sms-nonbus', 'dba-standby-bus', 'dba-standby-nonbus',
                        'dba-standby-nonbus-nowarn', 'hosting-standby-bus', 'hosting-standby-nonbus',
                        'janssst-sms-nonbus', 'liekejo-sms-bus', 'liekejo-sms-nonbus', 'network-standby-bus',
                        'network-standby-nonbus', 'spruyma-bus-sms', 'spruyma-nonbus-sms', 'spruyma-standby-bus',
                        'spruyma-standby-nonbus', 'vanropi-bus-sms', 'vanropi-nonbus-sms', 'vermema-sms-nonbus', 
                        'win-standby-bus', 'win-standby-nonbus'
                      )
                    and senddate >= add_months(trunc(sysdate, 'MM'), -6)
              group by clientname, trunc(senddate, 'MM')
            )
     )
where ranking <= 10
order by sendmonth, ranking, clientname;





set linesize 140
set pages 9999

column counted format 9G999G999
column month_sum format 9G999G999
column pct format 990D99
column clientname format a30
column systemname format a30
break on begin_date skip 1 on end_date skip 1
compute sum of counted on begin_date

select sendmonth begin_date, add_months(sendmonth, 1) - 1 end_date, ranking, clientname, systemname, counted, month_sum,
       (100/month_sum) * counted pct
from ( select sendmonth, clientname, systemname, counted,
              dense_rank () over ( partition by sendmonth order by counted desc) ranking,
              sum(counted) over (partition by sendmonth) month_sum
       from ( select trunc(senddate, 'MM') sendmonth, clientname, systemname, count(*) counted
              from stats_200804
              where notification_group in
                      ( 'bvp-sms', 'bvp-sms-bus', 'bvp-sms-nonbus', 'dba-standby-bus', 'dba-standby-nonbus',
                        'dba-standby-nonbus-nowarn', 'hosting-standby-bus', 'hosting-standby-nonbus',
                        'janssst-sms-nonbus', 'liekejo-sms-bus', 'liekejo-sms-nonbus', 'network-standby-bus',
                        'network-standby-nonbus', 'spruyma-bus-sms', 'spruyma-nonbus-sms', 'spruyma-standby-bus',
                        'spruyma-standby-nonbus', 'vanropi-bus-sms', 'vanropi-nonbus-sms', 'vermema-sms-nonbus', 
                        'win-standby-bus', 'win-standby-nonbus'
                      )
                    and senddate >= add_months(trunc(sysdate, 'MM'), -3)
              group by clientname, trunc(senddate, 'MM'), systemname
            )
     )
where ranking <= 20
order by sendmonth, ranking, clientname;
