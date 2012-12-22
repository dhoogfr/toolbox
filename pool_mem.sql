col area for a30
col megs for 999,999.0
compute sum of megs on report
break on report
select area,sum(megs) megs from (
select case when name in ('fixed_sga','free memory', 'buffer_cache','log_buffer')
  then name
  else pool end Area
,(bytes/(1024*1024)) Megs from v$sgastat)
group by area
/

