select
    a.name,
    avg(b.value)
from
    v$statname a,
    v$sesstat b
where
    a.statistic# = b.statistic#
    and a.name like '%uga%'
group by
    a.name
