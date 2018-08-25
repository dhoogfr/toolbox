-- Generate emcli (script) commands to set the preferred sysdba credential for databases that have not yet a preferred sysdba credential set
-- The named credential set depends on which admin group the database belongs to
-- (change the mapping to fit your needs. If you also created manual groups, duplicates can occur)
-- No password testing is done, but can be added in the emcli command as parameter

select
  'set_preferred_credential(set_name="DBCredsSYSDBA", target_name="' 
   || tgts.target_name 
   || '",target_type="' 
   || tgts.target_type 
   || '",credential_name="' 
   ||  ( case gdm.composite_target_name
          when 'evol-MIC-Grp'   then 'ORADB_DEFEVOPRD_SYS'
          when 'evol-PRD-Grp'   then 'ORADB_DEFEVOPRD_SYS'
          when 'evol-UAT-Grp'   then 'ORADB_DEFEVOACC_SYS'
          when 'evol-TST-Grp'   then 'ORADB_DEFEVOTST_SYS'
          when 'evol-DEV-Grp'   then 'ORADB_DEFEVODEV_SYS'
          when 'bi-MIC-Grp'     then 'ORADB_DEFEVOPRD_SYS'
          when 'bi-PRD-Grp'     then 'ORADB_DEFEVOPRD_SYS'
          when 'bi-UAT-Grp'     then 'ORADB_DEFEVOACC_SYS'
          when 'bi-TST-Grp'     then 'ORADB_DEFEVOTST_SYS'
          when 'bi-DEV-Grp'     then 'ORADB_DEFEVODEV_SYS'
          when 'dots-MIC-Grp'   then 'ORADB_DEFDOTSPRD_SYS'
          when 'dots-PRD-Grp'   then 'ORADB_DEFDOTSPRD_SYS'
          when 'dots-UAT-Grp'   then 'ORADB_DEFDOTSACC_SYS'
          when 'dots-TST-Grp'   then 'ORADB_DEFDOTSTST_SYS'
          when 'dots-DEV-Grp'   then 'ORADB_DEFDOTSDEV_SYS'
          when 'infra-PRD-Grp'  then 'ORADB_DEFEVOPRD_SYS'
          when 'infra-TST-Grp'  then 'ORADB_DEFEVOPRD_SYS'
          when 'misc-MIC-Grp'   then 'ORADB_DEFEVOPRD_SYS'
          when 'misc-PRD-Grp'   then 'ORADB_DEFEVOPRD_SYS'
          when 'syn-PRD-Grp'    then 'ORADB_DEFEVOPRD_SYS'
         end
       )
   || '",'
   || ')'
--  tgts.target_name,
--  tgts.target_type,
--  tgts.type_qualifier3,
--  nvl(composite_target_name, 'Unassigned') group_name
from
  mgmt$target                                         tgts
  join mgmt$group_derived_memberships                 gdm
    on ( tgts.target_guid = gdm.member_target_guid
       )
where
  tgts.target_type in
    ( 'oracle_database', 'oracle_pdb', 'rac_database'
    )
  and target_guid not in
    ( select
        tcreds.target_guid
      from
        em_nc_creds                                         creds
        join em_target_creds_e                              tcreds
        on ( creds.cred_guid = tcreds.cred_guid
           )
      where
        creds.cred_type_name = 'DBCreds'
        and creds.cred_scope = 1
        and tcreds.set_name = 'DBCredsSYSDBA'
        and tcreds.is_default = 0
    )
  and ( composite_target_guid is null 
        or composite_target_guid not in
          ( select
              composite_target_guid
            from
              mgmt$group_derived_memberships
            where
              member_target_type = 'composite'
           )
      )
order by
  tgts.target_name
;
