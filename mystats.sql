col name for a60
col value for 99999999999999
select name, value
from v$mystat s, v$statname n
where n.statistic# = s.statistic#
and name like nvl('&event_name',name)
/
