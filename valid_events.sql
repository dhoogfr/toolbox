select KSLEDNAM event from  x$ksled
where KSLEDNAM like nvl('&event_name',KSLEDNAM)
order by 1
/
