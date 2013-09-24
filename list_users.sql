set linesize 250
set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column username format a20
column created format a10
column lock_date format a10
column expiry_date format a11
column profile format a20
column account_status format a25
column default_tablespace format a20
column temporary_tablespace format a20
column password format a20
column password_versions format a10 heading "P VERSIONS"
column default_consumer_group format a25 heading "INITIAL CONSUMER GROUP"


select 
  u.name username, 
  to_char(u.ctime, 'DD/MM/YYYY') created, 
  p.name profile,
  m.status account_status,
  to_char(decode (u.astatus, 4, u.ltime, 5, u.ltime, 6, u.ltime, 8, u.ltime, 9, u.ltime, 10, u.ltime,  to_date(NULL)), 'DD/MM/YYYY') lock_date,
  to_char(decode (u.astatus, 1, u.exptime, 2, u.exptime, 5, u.exptime, 6, u.exptime, 9, u.exptime, 10, u.exptime,
                    decode (u.ptime, 
                             '', to_date(NULL),
                             decode (pr.limit#, 
                                       2147483647, to_date(NULL),
                                       decode (pr.limit#, 
                                                 0, decode (dp.limit#, 
                                                             2147483647, to_date(NULL), 
                                                             u.ptime + dp.limit#/86400
                                                           ),
                                                 u.ptime + pr.limit#/86400
                                              )
                                    )
                           )
                 ), 'DD/MM/YYYY') expiry_date,
  dts.name default_tablespace, 
  tts.name tempory_tablespace, 
  u.password password,
  nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP') initial_rsrc_consumer_group,
  decode(length(u.password),16,'10G ',NULL)||NVL2(u.spare4, '11G ' ,NULL) password_versions
from 
  sys.user$ u 
    left outer join sys.resource_group_mapping$ cgm
    on ( cgm.attribute = 'ORACLE_USER' 
         and cgm.status = 'ACTIVE' 
         and cgm.value = u.name
        ),
  sys.ts$ dts, 
  sys.ts$ tts, 
  sys.profname$ p,
  sys.user_astatus_map m, 
  sys.profile$ pr, 
  sys.profile$ dp
where
  u.datats# = dts.ts#
  and u.resource$ = p.profile#
  and u.tempts# = tts.ts#
  and u.astatus = m.status#
  and u.type# = 1
  and u.resource$ = pr.profile#
  and dp.profile# = 0
  and dp.type#=1
  and dp.resource#=1
  and pr.type# = 1
  and pr.resource# = 1
  and u.name like nvl('&1', '%')
order by
  username
;

undef 1
