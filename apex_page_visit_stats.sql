with page_hourly_counts
as ( 
  select
    trunc(view_date, 'HH') view_day_hour,
    application_name, 
    page_name,
    count(*) counted_views
  from
    apex_workspace_activity_log
  where
    view_date >= to_date('03/06/2024 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
    and view_date <= to_date('04/06/2024 12:00:00', 'DD/MM/YYYY HH24:MI:SS')
  group by
    trunc(view_date, 'HH'),
    application_name,
    page_name
),
page_hourly_rank
as (
  select
    view_day_hour,
    application_name,
    page_name,
    counted_views,
    row_number() over (
      partition by view_day_hour, application_name
      order by counted_views desc
    ) as rank
  from
    page_hourly_counts
)
select
  view_day_hour,
  application_name,
  page_name,
  counted_views
from
  page_hourly_rank
where
  rank <= 5
order by
  view_day_hour,
  application_name,
  rank
;


with page_hourly_counts
as ( 
  select
    trunc(view_date, 'HH') view_day_hour,
--    application_name, 
--    page_name,
    count(*) counted_views
  from
    apex_workspace_activity_log
  where
    view_date >= to_date('03/06/2024 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
    and view_date <= to_date('04/06/2024 12:00:00', 'DD/MM/YYYY HH24:MI:SS')
  group by
    trunc(view_date, 'HH')
--    application_name
    --page_name
),
page_hourly_rank
as (
  select
    view_day_hour,
--    application_name,
    --page_name,
    counted_views,
    row_number() over (
      partition by view_day_hour --, application_name
      order by counted_views desc
    ) as rank
  from
    page_hourly_counts
)
select
  view_day_hour,
--  application_name,
--  page_name,
  counted_views
from
  page_hourly_rank
where
  rank <= 5
order by
  view_day_hour,
--  application_name,
  rank
;