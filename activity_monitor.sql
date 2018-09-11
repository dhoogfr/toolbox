set echo off
set feedback off

set linesize 150
set pages 9999

column space_limit_mb format 999G999D99
column space_used_mb format 999G999D99
column space_reclaimable_mb format 999G999D99
column percent_space_used format 00D99
column percent_space_reclaimable format 00D99

compute sum of space_used_mb on report
compute sum of space_reclaimable_mb on report
compute sum of percent_space_used on report
compute sum of percent_space_reclaimable on report
compute sum of number_of_files on report;

break on space_limit_mb on report

select fusg.file_type, decode(nvl2(ra.name, ra.space_limit, 0), 0, 0, nvl(ra.space_limit, 0))/1048576 space_limit_mb, 
       decode(nvl2(ra.name, ra.space_limit, 0), 0, 0, nvl(fusg.space_used, 0))/1048576 space_used_mb,
       decode(nvl2(ra.name, ra.space_limit, 0), 0, 0, round(nvl(fusg.space_used, 0)/ra.space_limit, 4) * 100) percent_space_used,
       decode(nvl2(ra.name, ra.space_limit, 0), 0, 0, nvl(fusg.space_reclaimable, 0))/1048576 space_reclaimable_mb,
       decode(nvl2(ra.name, ra.space_limit, 0), 0, 0, round(nvl(fusg.space_reclaimable, 0)/ra.space_limit, 4) * 100) percent_space_reclaimable,
       nvl2(ra.name, fusg.number_of_files, 0) number_of_files
from v$recovery_file_dest ra,
     ( select 'CONTROLFILE' file_type,
              sum( case when ceilasm = 1 and name like '+%'
                        then ceil(((block_size*file_size_blks)+1)/1048576)*1048576
                        else block_size*file_size_blks
                   end
                 ) space_used, 
              0 space_reclaimable, count(*) number_of_files
       from v$controlfile,
            ( select /*+ no_merge*/ ceilasm 
              from x$krasga
            )
       where is_recovery_dest_file = 'YES'
       union all
       select 'ONLINELOG' file_type,
              sum( case when ceilasm = 1 and member like '+%'
                        then ceil((l.bytes+1)/1048576)*1048576
                        else l.bytes
                   end
                 ) space_used,
                 0 space_reclaimable, count(*) number_of_files
       from ( select group#, bytes
              from v$log
              union
              select group#, bytes
              from v$standby_log
            ) l, v$logfile lf,
            ( select /*+ no_merge */ ceilasm
              from x$krasga
            )
       where l.group# = lf.group#
             and lf.is_recovery_dest_file = 'YES'
       union all
       select 'ARCHIVELOG' file_type,
              sum(al.file_size) space_used,
              sum( case when dl.rectype = 11 
                        then al.file_size
                        else 0 
                   end
                 ) space_reclaimable,
              count(*) number_of_files
       from ( select recid,
                     case when ceilasm = 1 and name like '+%'
                          then ceil(((blocks*block_size)+1)/1048576)*1048576
                          else blocks * block_size
                     end file_size
              from v$archived_log, 
                   ( select /*+ no_merge */ ceilasm
                     from x$krasga
                   )
              where is_recovery_dest_file = 'YES'
                    and name is not null
            ) al,
            x$kccagf dl
       where al.recid = dl.recid(+)
             and dl.rectype(+) = 11
       union all
       select 'BACKUPPIECE' file_type,
              sum(bp.file_size) space_used,
              sum ( case when dl.rectype = 13 
                         then bp.file_size
                         else 0 
                    end
                  ) space_reclaimable, 
              count(*) number_of_files
       from ( select recid,
                     case when ceilasm = 1 and handle like '+%'
                          then ceil((bytes+1)/1048576)*1048576
                          else bytes
                     end file_size
              from v$backup_piece,
                   ( select /*+ no_merge */ ceilasm 
                     from x$krasga
                   )
              where is_recovery_dest_file = 'YES' 
                    and handle is not null
            ) bp,
            x$kccagf dl
       where bp.recid = dl.recid(+)
             and dl.rectype(+) = 13
       union all
       select 'IMAGECOPY' file_type,
       sum(dc.file_size) space_used,
       sum( case when dl.rectype = 16 
            then dc.file_size
            else 0 end
          ) space_reclaimable,
       count(*) number_of_files
       from ( select recid, 
                     case when ceilasm = 1 and name like '+%' 
                          then ceil(((blocks*block_size)+1)/1048576)*1048576
                          else blocks * block_size
                     end file_size
              from v$datafile_copy,
                   ( select /*+ no_merge */ ceilasm 
                     from x$krasga
                   )
              where is_recovery_dest_file = 'YES'
                    and name is not null
            ) dc,
            x$kccagf dl
       where dc.recid = dl.recid(+)
       and dl.rectype(+) = 16
       union all
       select 'FLASHBACKLOG' file_type,
              nvl(fl.space_used, 0) space_used, 
              nvl(fb.reclsiz, 0) space_reclaimable,
              nvl(fl.number_of_files, 0) number_of_files
       from ( select sum( case when ceilasm = 1 and name like '+%'
                               then ceil((fl.bytes+1)/1048576)*1048576
                               else bytes
                          end
                        ) space_used,
                     count(*) number_of_files
              from v$flashback_database_logfile fl,
                   ( select /*+ no_merge */ ceilasm 
                     from x$krasga
                   )
            ) fl,
            ( select sum(to_number(fblogreclsiz)) reclsiz 
              from x$krfblog
            ) fb 
    ) fusg
order by file_type;

clear breaks

set pagesize 999
set linesize 140

column name format a25 heading "tablespace name" 
column space_mb format 99g999g990D99 heading "curr df mbytes" 
column maxspace_mb format 99g999g990D99 heading "max df mbytes" 
column used format 99g999g990D99 heading "used mbytes" 
column df_free format 99g999g990D99 heading "curr df free mbytes"
column maxdf_free format 99g999g990D99 heading "max df free mbytes"
column pct_free format 990D99 heading "% free"
column pct_maxfile_free format 990D99 heading "% maxfile free"

break on report

compute sum of space_mb on report
compute sum of maxspace_mb on report
compute sum of df_free on report
compute sum of maxdf_free on report
compute sum of used on report

 
select df.tablespace_name name, df.space space_mb, df.maxspace maxspace_mb, (df.space - nvl(fs.freespace,0)) used,
       nvl(fs.freespace,0) df_free, (nvl(fs.freespace,0) + df.maxspace - df.space) maxdf_free, 
       100 * (nvl(fs.freespace,0) / df.space) pct_free, 
       100 * ((nvl(fs.freespace,0) + df.maxspace - df.space) / df.maxspace) pct_maxfile_free
from ( select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_data_files
       group by tablespace_name
       union all
       select tablespace_name, sum(bytes)/1024/1024 space, sum(greatest(maxbytes,bytes))/1024/1024 maxspace
       from dba_temp_files
       group by tablespace_name
     ) df,
     ( select tablespace_name, sum(bytes)/1024/1024 freespace
       from dba_free_space
       group by tablespace_name
     ) fs
where df.tablespace_name = fs.tablespace_name(+)
order by name;

clear breaks


column hour_arch_size format 99G999D99
column hour_arch# format 9G999
column graph format a15
column dayname format a12
column dayhour format a18

break on dayname skip 1

select to_char(trunc(completion_time, 'HH'), 'DD/MM/YYYY HH24:MI') dayhour, sum(blocks * block_size)/1024/1024 hour_arch_size, count(*) hour_arch#,
       rpad('*',floor(count(*)),'*') graph
from v$archived_log
where standby_dest = 'NO'
      and completion_time >= trunc(sysdate, 'HH') - 4/24
group by trunc(completion_time, 'HH')
order by dayhour;

clear breaks