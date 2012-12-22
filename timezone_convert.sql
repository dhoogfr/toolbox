create or replace function timezone_convert (UnixTimeA in number,UnixTimeZoneA in varchar2) return Date
is
 JulDate date := to_date('01-JAN-1970 00:00:00','DD-MON-YYYY HH24:MI:SS');
 LocalTimeZone varchar(6);
begin
 select dbtimezone into LocalTimeZone from dual ;
 return CAST(FROM_TZ(CAST(JulDate+(UnixTimeA/86400) AS TIMESTAMP), UnixTimeZoneA) AT TIME ZONE LocalTimeZone AS DATE);
exception
 when OTHERS then raise_application_error(-20015,'Error in timezone_convert',true);
end;
/
sho errors function timezone_convert
