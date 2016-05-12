column statistic format a50
column value for 999,999


select * 
from V$PX_PROCESS_SYSSTAT 
where statistic like '%In Use%';
