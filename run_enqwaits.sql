/**********************************************************************
 * File:        run_enqwaits.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        05Feb01
 *
 * Description:
 *      Script to execute the ENQWAITS stored procedure.
 *
 * Modifications:
 *	TGorman	05feb01	written
 *********************************************************************/
set serveroutput on size 1000000 feedback off trimspool on termout off
col instance new_value V_INSTANCE noprint
select  lower(replace(t.instance,chr(0),'')) instance
from    sys.v_$thread        t,
        sys.v_$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));
spool enqwaits_&&V_INSTANCE
execute enqwaits
spool off
set termout on
ed enqwaits_&&V_INSTANCE..lst
