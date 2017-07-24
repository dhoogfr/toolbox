set linesize 250
set verify off

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

column username format a30
column created format a10
column lock_date format a10
column expiry_date format a11
column profile format a25
column account_status format a20
column default_tablespace format a20
column temporary_tablespace format a20
--column password format a20
column password_versions format a17 heading "PWD VERSIONS"
--column default_consumer_group format a25 heading "INITIAL CONSUMER GROUP"
column authentication_type format a10 heading "PWD TYPE"
column password_change_date format a12 heading "LAST PWD|CHANGE DATE"
column last_login format a22 heading "LAST LOGIN"
column oracle_maintained format a3 heading "DEF"
column common format a3 heading "COM"

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
  to_char(ptime, 'DD/MM/YYYY') password_change_date,
  to_char(from_tz( to_timestamp (to_char(u.spare6, 'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'), '0:00') at time zone sessiontimezone, 'DD/MM/YYYY HH24:MI TZH')  last_login,
  dts.name default_tablespace, 
  tts.name tempory_tablespace,
  decode(u.password, 'GLOBAL',   'GLOBAL',
                   'EXTERNAL', 'EXTERNAL',
                   'PASSWORD') authentication_type,
  decode(bitand(u.spare1, 128), 128, 'YES', 'NO') common,
  decode(bitand(u.spare1, 256), 256, 'Y', 'N') oracle_maintained,
--  u.password password,
--  nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP') initial_rsrc_consumer_group,
--  decode(length(u.password),16,'10G ',NULL)||NVL2(u.spare4, '11G ' ,NULL) password_versions
    ( decode (regexp_instr (nvl2 (u.password, u.password, ' '), '^                $'), 0, decode(length(u.password), 16, '10G ', NULL), '' ) || 
      decode (regexp_instr (regexp_replace (nvl2 (u.spare4, u.spare4, ' '),'S:000000000000000000000000000000000000000000000000000000000000', 'not_a_verifier'), 'S:'), 0, '', '11G ') ||
      decode (regexp_instr (nvl2 (u.spare4, u.spare4, ' '), 'T:'), 0, '', '12C ') ||
      decode (regexp_instr (regexp_replace ( nvl2(u.spare4, u.spare4, ' '), 'H:00000000000000000000000000000000', 'not_a_verifier'), 'H:'), 0, '', 'HTTP ')
    ) password_versions
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
  and ( u.astatus = m.status# 
        or u.astatus = (m.status# + 16 - BITAND(m.status#, 16))
      )
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
