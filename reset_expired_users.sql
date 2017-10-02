/* Reset the password of expired users to their current value, to open the account again without having the actually change the password
   Accepts a username (with wildcards) as input parameter. If no input parameter was given, it will run for all users with status expired / expired(grace)
   Note that if in the profile a password_reuse_max is set, the profile for that user needs to be changed before this procedure will work

   Need to run as a sysdba user
   Passwords of common users need to be changed on CDB level, PDB users from within the PDB

   Tested on 12cR1
*/

set feedback off
column inputpar01 new_value 1 noprint
select 1 inputpar01 from dual where 1=2;
set feedback 6

pause Unless a username was given as parameter, this script will reset the password for all users with an account status of expired / expired(grace), if this is not what you want: ctrl+c


DECLARE

  l_sep     varchar2(1);

BEGIN

  for r_users in
  ( select
      u.name,
      u.password,
      u.spare4
    from
      sys.user$               u,
      sys.user_astatus_map    m
    where
      ( u.astatus = m.status# 
        or u.astatus = (m.status# + 16 - BITAND(m.status#, 16))
      )
      and m.status in ('EXPIRED', 'EXPIRED(GRACE)')
      -- skip oracle maintained users
      -- and decode(bitand(u.spare1, 256), 256, 'Y', 'N') = 'N'
      and u.name like nvl('&1', '%')
    order by
      u.name
  )
  loop

    BEGIN
      
      if ( r_users.spare4 is not null
           and r_users.password is not null
         )
      then
        l_sep := ';';
      else
        l_sep := '';
      end if;

      execute immediate 'alter user "' || r_users.name || '" identified by values ''' || r_users.spare4 || l_sep || r_users.password || '''';
      dbms_output.put_line('SUCCESS - Password reset for user ' || r_users.name);

    EXCEPTION
      when others then
        dbms_output.put_line('FAILURE - Could not reset password for user: ' || r_users.name);
        dbms_output.put_line(SQLERRM);
    END;

  end loop;

END;
/
