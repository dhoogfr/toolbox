set linesize 230
set pages 50000

column svrname format a15
column dirname format a30
column path format a20
column local format a20

select
  distinct
  svr.svrname,
  svr.dirname,
  chn.path,
  chn.local
from
  v$dnfs_servers svr,
  v$dnfs_channels chn
where
  svr.svrname = chn.svrname
order by
  svr.svrname,
  svr.dirname,
  chn.path,
  chn.local
;
