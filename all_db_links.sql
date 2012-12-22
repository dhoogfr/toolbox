column owner format a15
column username format a15
column password format a15
column host format a20
column db_link format a30

select u.name owner, l.name db_link, l.userid username, l.password password, l.host host 
from sys.link$ l, sys.user$ u 
where l.owner# = u.user# 
order by l.name;
