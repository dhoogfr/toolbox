#!/usr/bin/env perl
#
# Author: Bertrand Drouvot
# Visit my blog : http://bdrouvot.wordpress.com/
# V1.0 (2013/01)
# V1.1 (2013/02): Adding the asmiostat type
# V1.2 (2013/03): Adding IP to asmiostat (For Exadata Cells)
#
# Description:
# Utility used to display real time informations based on cumulative views
# It does not create objects into the database
# It basically takes a snapshot each second (default interval) of the cumulative view and computes the differences
# with the previous snapshot
# It is oracle RAC aware : you can work on all the instances, a subset or the local one
# You have to set oraenv on one instance of the database you want to diagnose first
# You can choose the number of snapshots to display and the time to wait between snapshots
#
# Usage:
# ./real_time.pl -help
#
# Chek for new version : http://bdrouvot.wordpress.com/perl-scripts-2/
#
#----------------------------------------------------------------#

BEGIN {
    die "ORACLE_HOME not set\n" unless $ENV{ORACLE_HOME};
    unless ($ENV{OrAcLePeRl}) {
       $ENV{OrAcLePeRl} = "$ENV{ORACLE_HOME}/perl";
       $ENV{PERL5LIB} = "$ENV{PERL5LIB}:$ENV{OrAcLePeRl}/lib:$ENV{OrAcLePeRl}/lib/site_perl";
       $ENV{LD_LIBRARY_PATH} = "$ENV{LD_LIBRARY_PATH}:$ENV{ORACLE_HOME}/lib32:$ENV{ORACLE_HOME}/lib";
       exec "$ENV{OrAcLePeRl}/bin/perl", $0, @ARGV;
    }
}

use strict;
use DBI;
use DBD::Oracle qw(:ora_session_modes);

use Getopt::Long; 

our $real_time_type='';
our %options; 
our $debug=0;
our $interval=1; 
our $count=999999;
our $topn=10;
our $showinst=0;
our $rac=0;
our $inst_type='rdbms';
our $dbh;
our $instpattern='all';
our $stat_pattern='';
our $owner_pattern='';
our $seg_pattern='';
our $include_sys_pattern='N';
our $waitclass_pattern='';
our $event_pattern='';
our $name_pattern='';
our $pool_pattern='';
our $eq_pattern='';
our $eqtype_pattern='';
our $reqreason_pattern='';
our $space_pattern='';
our $sid_pattern='';
our $sqlid_pattern='';
our $fg_pattern='';
our $ip_pattern='';
our $dg_pattern='';
our $show_pattern='dg';
our $dgid_sql_pattern='';
our $fg_sql_pattern='';
our $dg_suffixe='';
our $instid_pattern='inst_id';
our $sqlsuffixe;
our $sql1;
our $main_sql='';
our %instances;
our %asm_dg;
our %asm_fg;
our %showinstances=();
our %sql_patterns;
our %diffsnaps;
our %rtvalues;
our %pkeys;
our $bkey;
our @ekey;
our %ckeys=();
our @array_of_ckeys_description=();
our @array_of_display_keys=();
our @array_of_ckey=();
our @delta_fields;
our $global_sql_pattern='';
our @array_of_report_header;
our $report_format_values;
our @report_fields_values;
our $seconds;
our $minuts;
our $hours;
our %sort_fields;
our $sort_field_pattern='';

sub main {
&get_the_options(@ARGV);

if ($real_time_type =~ m/^sysstat$/i ) {
	$sql_patterns{'name'}=$stat_pattern;
	$main_sql="select inst_id,name,value from gv\$sysstat where 1=1 ";
	$pkeys{0}='%30s';
	$pkeys{1}='%70s';
	@array_of_display_keys=({0=>'y',1=>'y'});
	@delta_fields=(2);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %5s %-60s %5s %-20s\n",'','INST_NAME','','NAME','','VALUE']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %5s %-60s %5s %-20s\n";
	@report_fields_values=(1,2);
	$sort_fields{2}='VALUE';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='VALUE'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^system_event$/i ) {
	$sql_patterns{'event'}=$event_pattern;
	$sql_patterns{'wait_class'}=$waitclass_pattern;
	$main_sql="select inst_id,EVENT, TIME_WAITED_MICRO,TOTAL_WAITS from gv\$system_event where 1=1 ";
	$pkeys{0}='%30s';
	$pkeys{1}='%70s';
	@array_of_display_keys=({0=>'y',1=>'y'});
	@delta_fields=(2,3);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-65s %2s %-20s %2s %-20s %2s %-10s\n",'','INST_NAME','','EVENT','','NB_WAITS','','TIME_WAITED_MICRO','','ms/Wait']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-65s %2s %-20s %2s %-20s %2s %.3f\n";
	@report_fields_values=(1,3,2,"2/3/1000");
	$sort_fields{2}='TIME_WAITED_MICRO';
	$sort_fields{3}='NB_WAITS';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='NB_WAITS'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^sess_event$/i ) {
	$sql_patterns{'ev.event'}=$event_pattern;
	$sql_patterns{'s.sid'}=$sid_pattern;
	$sql_patterns{'s.sql_id'}=$sqlid_pattern;
	$instid_pattern="ev.inst_id";
	$main_sql="select ev.inst_id,s.sql_id,ev.EVENT,ev.TIME_WAITED_MICRO,ev.TOTAL_WAITS,s.sid,s.serial# from gv\$session_event ev,gv\$session s where ev.wait_class !='Idle' and s.sid=ev.sid and ev.inst_id=s.inst_id and (s.sid,s.inst_id) not in (select distinct sid,inst_id from gv\$mystat) ";
	$pkeys{0}='%30s';
	$pkeys{1}='%30s';
	$pkeys{2}='%70s';
	$pkeys{5}='%30s';
	$pkeys{6}='%30s';
	@array_of_display_keys=({0=>'y',1=>'y',2=>'y',5=>'y',6=>'y'});
	# Remove sid,serial# from the key to sum on all sid
	@array_of_ckeys_description=({0=>'%30s',1=>'%30s',2=>'%70s'});

	@delta_fields=(3,4);

	if ($sid_pattern)
	{
		@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-8s %1s %-15s %2s %-40s %2s %-20s %2s %-20s %2s %-10s\n",'','INST_NAME','','SID','','SQL_ID','','EVENT','','NB_WAITS','','TIME_WAITED_MICRO','','ms/Wait']);
		$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-8s %1s %-15s %2s %-40s %2s %-20s %2s %-20s %2s %.3f\n";
		@report_fields_values=(5,1,2,4,3,"3/4/1000");
	}
	else
	{
		@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-15s %2s %-50s %2s %-20s %2s %-20s %2s %-10s\n",'','INST_NAME','','SQL_ID','','EVENT','','NB_WAITS','','TIME_WAITED_MICRO','','ms/Wait']);
		$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-15s %2s %-50s %2s %-20s %2s %-20s %2s %.3f\n";
		@report_fields_values=(1,2,4,3,"3/4/1000");
	}

	$sort_fields{3}='TIME_WAITED_MICRO';
	$sort_fields{4}='NB_WAITS';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='NB_WAITS'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^sess_stat/i ) {
	$sql_patterns{'sn.name'}=$stat_pattern;
	$sql_patterns{'ss.sid'}=$sid_pattern;
	$sql_patterns{'ss.sql_id'}=$sqlid_pattern;
	$instid_pattern="ss.inst_id";
	$main_sql="
	select ss.inst_id, ss.sql_id, sn.name,se.VALUE,ss.sid,ss.serial#
	from gv\$session ss,
	gv\$sesstat se,
	gv\$statname sn
	where se.STATISTIC# = sn.STATISTIC#
	and ss.inst_id = se.inst_id
	and se.inst_id = sn.Inst_id
	and se.SID = ss.SID
	and se.value > 0
	and (ss.sid,ss.inst_id) not in (select distinct sid,inst_id from gv\$mystat) ";
	$pkeys{0}='%30s';
	$pkeys{1}='%30s';
	$pkeys{2}='%70s';
	$pkeys{4}='%30s';
	$pkeys{5}='%30s';
	@array_of_display_keys=({0=>'y',1=>'y',2=>'y',5=>'y'});
	# Remove sid,serial# from the key to sum on all sid
	@array_of_ckeys_description=({0=>'%30s',1=>'%30s',2=>'%70s'});

	@delta_fields=(3);

	if ($sid_pattern)
	{
		@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-10s %2s %-13s %2s %-70s %2s %-20s\n",'','INST_NAME','','SID','','SQL_ID','','NAME','','VALUE']);
		$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-10s %2s %-13s %2s %-70s %2s %-20s\n";
		@report_fields_values=(4,1,2,3);
	}
	else
	{
		@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-13s %2s %-70s %2s %-20s\n",'','INST_NAME','','SQL_ID','','NAME','','VALUE']);
		$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-13s %2s %-70s %2s %-20s\n";
		@report_fields_values=(1,2,3);
	}

	$sort_fields{3}='VALUE';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='VALUE'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^event_histogram$/i ) {
	$sql_patterns{'event'}=$event_pattern;
	$main_sql="select inst_id,event, wait_time_milli, wait_count from gv\$event_histogram where 1=1  ";
	$pkeys{0}='%30s';
	$pkeys{1}='%70s';
	$pkeys{2}='%30s';
	@array_of_display_keys=({0=>'y',1=>'y',2=>'y'});
	@delta_fields=(3);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %5s %-60s %5s %-20s %5s %-20s\n",'','INST_NAME','','EVENT','','WAIT_TIME_MS','','COUNT']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %5s %-60s %5s %-20s %5s %-20s\n";
	@report_fields_values=(1,2,3);
	$sort_fields{2}='WAIT_TIME_MS';
	$sort_fields{3}='COUNT';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='COUNT'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^sgastat$/i ) {
	$sql_patterns{'pool'}=$pool_pattern;
	$sql_patterns{'name'}=$name_pattern;
	$main_sql="select inst_id,pool,name,bytes from gv\$sgastat where 1=1 ";
	$pkeys{0}='%30s';
	$pkeys{1}='%30s';
	$pkeys{2}='%30s';
	@array_of_display_keys=({0=>'y',1=>'y',2=>'y'});
	@delta_fields=(3);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %5s %-30s %5s %-30s %5s %-30s\n",'','INST_NAME','','POOL','','NAME','','BYTES']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %5s %-30s %5s %-30s %5s %-30s\n";
	@report_fields_values=(1,2,3);
	$sort_fields{3}='BYTES';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='BYTES'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^asmiostat$/i ) {
        $inst_type='asm';
	my $ckey_cpt=0;	
	# The failgroup case (default one)
        $main_sql="select inst_id,group_number,disk_number,failgroup,reads,writes,read_errs,write_errs,read_time*1000,write_time*1000,bytes_read/1024,bytes_written/1024,regexp_replace(path,\'.*/\',\'\'),$interval from gv\$asm_disk_stat where mount_status ='CACHED'";
        $pkeys{0}='%30s';
        $pkeys{1}='%30s';
        $pkeys{2}='%30s';
        $pkeys{3}='%30s';
	# What need to be show
        my @show_fields = split (/,/,$show_pattern);
        # The IP case
        if (grep (/^ip$/i,@show_fields)) {
        if (grep (/^fg$/i,@show_fields)) {
	&usage_asmiostat();
	} else {
        $main_sql="select inst_id,group_number,disk_number,regexp_substr(path,'([[:digit:]]{1,3}\.[[:digit:]]{1,3})\.[[:digit:]]{1,3}(\.[[:digit:]]{1,3})'),reads,writes,read_errs,write_errs,read_time*1000,write_time*1000,bytes_read/1024,bytes_written/1024,regexp_replace(path,\'.*/\',\'\'),$interval from gv\$asm_disk_stat where mount_status ='CACHED'";
	$sql_patterns{"regexp_substr(path,'([[:digit:]]{1,3}\.[[:digit:]]{1,3})\.[[:digit:]]{1,3}(\.[[:digit:]]{1,3})')"}=$ip_pattern;
        }
	}
        foreach my $show (@show_fields) {
	if ($show =~ m/^inst$/i ){ 
	# group by ASM instance
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s'; 	
	$array_of_ckeys_description[$ckey_cpt]{13}='%10s';
	$array_of_display_keys[$ckey_cpt]{0}='y'; 
	$array_of_display_keys[$ckey_cpt]{13}='y';
	$ckey_cpt=$ckey_cpt+1; 
	}
        if ($show =~ m/^dg$/i ){
	# group by DG
	$array_of_ckeys_description[$ckey_cpt]{13}='%10s';
	$array_of_display_keys[$ckey_cpt]{13}='y';
	if (grep (/^inst$/i,@show_fields)) {
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s';
	$array_of_display_keys[$ckey_cpt]{0}='y';
	}
        $array_of_ckeys_description[$ckey_cpt]{1}='%30s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
	$ckey_cpt=$ckey_cpt+1; 
        }
        if ($show =~ m/^(fg|ip)$/i ){
	# group by FG or IP
        $array_of_ckeys_description[$ckey_cpt]{13}='%10s';
        $array_of_display_keys[$ckey_cpt]{13}='y';
	if (grep (/^inst$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{0}='%30s';
        $array_of_display_keys[$ckey_cpt]{0}='y';
        }
        if (grep (/^dg$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{1}='%30s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
        }
        $array_of_ckeys_description[$ckey_cpt]{3}='%30s';
        $array_of_display_keys[$ckey_cpt]{3}='y';
        $ckey_cpt=$ckey_cpt+1;
        }
        if ($show =~ m/^dsk$/i ){
	# group per disk
        $array_of_ckeys_description[$ckey_cpt]{13}='%10s';
        $array_of_display_keys[$ckey_cpt]{13}='y';
        if (grep (/^inst$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{0}='%30s';
        $array_of_display_keys[$ckey_cpt]{0}='y';
        }
        if (grep (/^dg$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{1}='%30s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
        }
        if (grep (/^(fgi|ip)$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{3}='%30s';
        $array_of_display_keys[$ckey_cpt]{3}='y';
        }
	$array_of_ckeys_description[$ckey_cpt]{12}='%30s';
        $array_of_display_keys[$ckey_cpt]{12}='y';
        $ckey_cpt=$ckey_cpt+1;
        }
	}
        	
        @delta_fields=(4,5,6,7,8,9,10,11);
        $report_format_values="%02d:%02d:%02d %1s %-6s %1s %-11s %1s %-11s %1s %-10s %1s %-7.0f %1s %-6.0f %1s %-7.1f %1s %-7.0f %1s %-6.0f %1s %-8.0f %1s %-7.0f %1s %-8.1f %1s %-7.0f %1s %-5s \n";
        @report_fields_values=(3,12,"4/13","10/13","8/4","10*1024/4",6,"5/13","11/13","9/5","11*1024/5",7);
	@array_of_report_header=(["%02d:%02d:%02d %51s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','','','Kby','','Avg','','AvgBy/','','Read','','','','Kby','','Avg','','AvgBy/','','Write'],["%02d:%02d:%02d %1s %-6s %1s %-11s %1s %-11s %1s %-10s %1s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','INST','','DG','','FG','','DSK','','Reads/s','','Read/s','','ms/Read','','Read','','Errors','','Writes/s','','Write/s','','ms/Write','','Write','','Errors'],["%02d:%02d:%02d %1s %-6s %1s %-11s %1s %-11s %1s %-10s %1s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','------','','-----------','','-----------','','----------','','-------','','------','','-------','','------','','------','','--------','','-------','','--------','','------','','------']);
        # The IP case
        if (grep (/^ip$/i,@show_fields)) {
	$report_format_values="%02d:%02d:%02d %1s %-6s %1s %-9s %1s %-15s %1s %-8s %1s %-7.0f %1s %-6.0f %1s %-7.1f %1s %-7.0f %1s %-6.0f %1s %-8.0f %1s %-7.0f %1s %-8.1f %1s %-7.0f %1s %-5s \n";
	@array_of_report_header=(["%02d:%02d:%02d %51s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','','','Kby','','Avg','','AvgBy/','','Read','','','','Kby','','Avg','','AvgBy/','','Write'],["%02d:%02d:%02d %1s %-6s %1s %-9s %1s %-15s %1s %-8s %1s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','INST','','DG','','IP (Cells)','','DSK','','Reads/s','','Read/s','','ms/Read','','Read','','Errors','','Writes/s','','Write/s','','ms/Write','','Write','','Errors'],["%02d:%02d:%02d %1s %-6s %1s %-9s %1s %-15s %1s %-8s %1s %-7s %1s %-6s %1s %-7s %1s %-7s %1s %-6s %1s %-8s %1s %-7s %1s %-8s %1s %-7s %1s %-6s\n",'','------','','---------','','---------------','','--------','','-------','','------','','-------','','------','','------','','--------','','-------','','--------','','------','','------']);
	}
        &go_sql_real_time;
}

if ($real_time_type =~ m/^librarycache$/i ) {
	$sql_patterns{'namespace'}=$space_pattern;
	$main_sql="select inst_id,namespace,reloads,INVALIDATIONS,GETS,GETHITS,PINS,PINHITS from gv\$librarycache where 1=1 ";
	$pkeys{0}='%30s';
	$pkeys{1}='%30s';
	@array_of_display_keys=({0=>'y',1=>'y'});
	@delta_fields=(2,3,4,5,6,7);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %5s %-15s %5s %-10s %5s %-13s %5s %-7s %5s %-8s %5s %-7s %5s %-8s\n",'','INST_NAME','','NAMESPACE','','RELOADS','','INVALIDATIONS','','GETS','','GETRATIO','','PINS','','PINRATIO']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %5s %-15s %5s %-10s %5s %-13s %5s %-7s %5s %-8.1f %5s %-7s %5s %-8.1f\n";
	@report_fields_values=(1,2,3,5,"5*100/4",7,"7*100/6");
	$sort_fields{2}='RELOADS';
	$sort_fields{3}='INVALIDATIONS';
	$sort_fields{4}='GETS';
	$sort_fields{6}='PINS';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='GETS'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^segments_stats$/i ) {
	$sql_patterns{'d.object_name'}=$seg_pattern;
	$sql_patterns{'d.owner'}=$owner_pattern;
	$sql_patterns{'s.STATISTIC_NAME'}=$stat_pattern;
	if ($include_sys_pattern =~ m/N/i) {
		$main_sql="select /*+ RULE */ s.inst_id,d.owner,d.object_name,d.subobject_name,d.object_type,s.STATISTIC_NAME,s.value,s.DATAOBJ# from gv\$segstat s,dba_objects d where s.DATAOBJ#=d.DATA_OBJECT_ID and s.obj#=d.object_id and d.owner <> 'SYS'";
	}
	else 
	{
		if ($include_sys_pattern =~ m/Y/i) {$main_sql="select /*+ RULE */ s.inst_id,d.owner,d.object_name,d.subobject_name,d.object_type,s.STATISTIC_NAME,s.value,s.DATAOBJ# from gv\$segstat s,dba_objects d where s.DATAOBJ#=d.DATA_OBJECT_ID and s.obj#=d.object_id"};
	}
	$pkeys{0}='%30s';
	$pkeys{7}='%30s';
	$pkeys{1}='%30s';
	$pkeys{2}='%128s';
	$pkeys{5}='%64s';
	@array_of_display_keys=({0=>'y',7=>'y',1=>'y',2=>'y',5=>'y'});
	@delta_fields=(6);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %3s %-15s %3s %-40s %3s %-40s %3s %-10s\n",'','INST_NAME','','OWNER','','OBJECT_NAME','','STAT_NAME','','VALUE']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %3s %-15s %3s %-40s %3s %-40s %3s %-10s\n";
	@report_fields_values=(1,2,5,6);
	$sort_fields{6}='VALUE';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='VALUE'};
	&go_sql_real_time;
}

if ($real_time_type =~ m/^enqueue_statistics$/i ) {
	$sql_patterns{'EQ_NAME'}=$eq_pattern;
	$sql_patterns{'EQ_TYPE'}=$eqtype_pattern;
	$sql_patterns{'REQ_REASON'}=$reqreason_pattern;
	$main_sql="select inst_id,EQ_NAME,EQ_TYPE,REQ_REASON,TOTAL_REQ#,TOTAL_WAIT#,SUCC_REQ#,FAILED_REQ#,CUM_WAIT_TIME from gv\$enqueue_statistics where 1=1 ";
	$pkeys{0}='%30s';
	$pkeys{1}='%70s';
	$pkeys{2}='%10s';
	$pkeys{3}='%70s';
	@array_of_display_keys=({0=>'y',1=>'y',2=>'y',3=>'y'});
	@delta_fields=(4,5,6,7,8);
	@array_of_report_header=(["%02d:%02d:%02d %1s %-10s %2s %-40s %2s %-5s %2s %-40s %2s %-10s %2s %-10s %2s %-10s %2s %-10s %2s %-10s\n",'','INST_NAME','','EQ_NAME','','EQ_TYPE','','REQ_REASON','','TOTAL_REQ','','TOTAL_WAIT','','SUCC_REQ','','FAILED_REQ','','WAIT_TIME']);
	$report_format_values="%02d:%02d:%02d %1s %-10s %2s %-40s %2s %-7s %2s %-40s %2s %-10s %2s %-10s %2s %-10s %2s %-10s %2s %-10s\n";
	@report_fields_values=(1,2,3,4,5,6,7,8);
	$sort_fields{4}='TOTAL_REQ';
	$sort_fields{5}='TOTAL_WAIT';
	$sort_fields{6}='SUCC_REQ';
	$sort_fields{7}='FAILED_REQ';
	$sort_fields{8}='WAIT_TIME';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='TOTAL_REQ'};
	&go_sql_real_time;
}
}
#
# Ctrl+C signal
#
$SIG{INT}= \&close;

sub close {
        print "Disconnecting from RDBMS...\n";
        $sql1->finish;
        $dbh->disconnect();
        exit 0;
}

sub get_the_options {
    my $help; 
    GetOptions('help|h' => \$help,
		'interval=i'=>\$interval,
		'count=i'=>\$count,
		'type=s' => \$real_time_type,
		'top:i' => \$topn,
		'inst:s' => \$instpattern,
		'waitclass:s' => \$waitclass_pattern,
		'event:s' => \$event_pattern,
		'name:s' => \$name_pattern,
		'pool:s' => \$pool_pattern,
		'eq_name:s' => \$eq_pattern,
		'eq_type:s' => \$eqtype_pattern,
		'namespace:s' => \$space_pattern,
		'req_reason:s' => \$reqreason_pattern,
		'sort_field:s' => \$sort_field_pattern,
		'segment:s' => \$seg_pattern,
		'owner:s' => \$owner_pattern,
		'sid:s' => \$sid_pattern,
		'sql_id:s' => \$sqlid_pattern,
		'fg:s' => \$fg_pattern,
		'ip:s' => \$ip_pattern,
		'dg:s' => \$dg_pattern,
		'show:s' => \$show_pattern,
		'include_sys:s' => \$include_sys_pattern,
		'statname:s' => \$stat_pattern) or &usage();

    &usage($real_time_type) if ((!$real_time_type) or  $help ); 
}

sub go_sql_real_time {
&connect_db;
&check_instance_type($inst_type);
&check_rac;
&build_instances;
if ( $inst_type =~ /asm/i) {&build_asm_dg_fg};
&build_rac_pattern;
&build_glob_sql_pattern;
&build_glob_sql;
&initialise_arrays;
&launch_loop;
}

sub connect_db {
$dbh = DBI->connect('dbi:Oracle:',"", "", { ora_session_mode => ORA_SYSDBA });
}
 
sub check_instance_type {
my $inst_type=$_[0];
debug("Instance Type: ".$inst_type);
my $sql1 = $dbh->prepare('select value from v$parameter where name=\'instance_type\' ');
$sql1->execute;

if ( $sql1->fetchrow_array =~ /$inst_type/i) {
        $sql1->finish;
}
else {
        print "\n\n ERROR : You must connect to a ".$inst_type." instance \n\n";
        $sql1->finish;
        $dbh->disconnect();
        exit 1;
}
}

sub check_rac {
my $sql1 = $dbh->prepare('select value  from v$parameter where name = \'cluster_database\'');
$sql1->execute;
if ( $sql1->fetchrow_array =~ /true/i) {
   $rac=1;
}
$sql1->finish;
}

sub build_instances {
my $sql1 = $dbh->prepare('select inst_id,instance_name, host_name from gv$instance');
$sql1->execute;
while ( my ($instid, $instname,$host) = $sql1->fetchrow_array) {
        $instances{$instname} = $instid;
}
$sql1->finish;
}

sub build_asm_dg_fg {
&build_asm_dg;
&build_asm_fg;
}

sub build_asm_dg {
my $sql1 = $dbh->prepare('select group_number,name from v$asm_diskgroup_stat');
$sql1->execute;
while ( my ($dgid, $dgname) = $sql1->fetchrow_array) {
        $asm_dg{$dgid} = $dgname;
}
$sql1->finish;
$dgid_sql_pattern=&build_in_pattern($dg_pattern,'group_number',%asm_dg);
}

sub build_asm_fg {
my $sql1 = $dbh->prepare('select distinct(failgroup) from v$asm_disk_stat');
$sql1->execute;
while ( my ($fgname) = $sql1->fetchrow_array) {
        $asm_fg{$fgname} = $fgname;
}
$sql1->finish;
$fg_sql_pattern=&build_in_pattern($fg_pattern,'failgroup',%asm_fg);
}

sub build_in_pattern {
 my $pattern=shift;
 my $column=shift;
 my %list_of_field=@_; 
 my %reverse_list_of_field = reverse %list_of_field;
 my @fields = split (/,/,$pattern);
 my $output_in_pattern=''; 	
 foreach my $field (@fields) {
        if (!exists  $reverse_list_of_field{uc($field)}) {
         print "\n\n ERROR : $field $column is not found !! \n";
         exit 1;
	} else {
	if (!$output_in_pattern) {
	$output_in_pattern=" and $column in ('"."$reverse_list_of_field{uc($field)}'";
	} else {
	$output_in_pattern=$output_in_pattern.",'$reverse_list_of_field{uc($field)}'";
	}
	}
 }
	($output_in_pattern)?$output_in_pattern=$output_in_pattern.")":"";
	return $output_in_pattern;
}

sub build_rac_pattern
{
if ($rac & ! ($instpattern =~ /all|current/i)) {
        my @fields = split (/,/,$instpattern);

        foreach my $instname (@fields) {

        if (!exists  $instances{uc($instname)}) {
              print "\n\n ERROR : The instance $instname is not found !! \n";
              $dbh->disconnect();
              exit 1;
        } else {
           $showinstances{$instname}=$instances{$instname};;
        }
        }
}

# If not rac put pattern as current

if (! $rac) {
$instpattern = 'current';
}

if ($instpattern =~ /current/i) {

my $sql1_sql = "select inst_id,instance_name, host_name from gv\$instance where inst_id = userenv('instance')";

my $sql1 = $dbh->prepare($sql1_sql);
$sql1->execute;
while ( my ($instid, $instname,$host) = $sql1->fetchrow_array) {
        $instances{$instname} = $instid;
}
$sql1->finish;
}

if (($rac & ($instpattern =~ /all|current/i)) | (! $rac & ($instpattern =~ /current/i))) {
        %showinstances = %instances;
}

# RAC : Create the SQL suffixe based on the instances to request on

# Case 1 : The current instance or list of instances
$sqlsuffixe = ((! $rac)  | ($rac & $instpattern =~ /current/i) ? " and ".$instid_pattern. " = userenv('instance')" : "");

# Case 2 : All the instances
# Nothing to do

if ($rac & ! ($instpattern =~ /all|current/i)) {

        foreach my $inst (keys %showinstances) {

        my $inst_id = $showinstances{$inst};

        if ($sqlsuffixe) {
        $sqlsuffixe = $sqlsuffixe." or ".$instid_pattern. " = $inst_id";
                }
        else
                {
        $sqlsuffixe = $sqlsuffixe." and (".$instid_pattern. " = $inst_id";
                }
        }
        $sqlsuffixe = $sqlsuffixe.")";

}
debug("sqlsuffixe: ".$sqlsuffixe);
# Reverse the hash for display usage (Report Section)
%showinstances = reverse %showinstances;
}

sub build_glob_sql_pattern {

	foreach my $column (keys %sql_patterns) {
	debug("column: ".$column);
	debug("pattern: ".$sql_patterns{$column});
	if ($sql_patterns{$column}) {$global_sql_pattern = $global_sql_pattern." and ".$column." like '".$sql_patterns{$column}."' "}
	}
	debug("global_sql_pattern: ".$global_sql_pattern);
}

sub build_glob_sql {
	$main_sql = $main_sql.$global_sql_pattern.$sqlsuffixe.$dgid_sql_pattern.$fg_sql_pattern; 
	debug("Main sql: ".$main_sql);
}

sub build_the_key {
	my @tab1 = @_;
	$bkey='';
	@ekey=();
	foreach my $id (sort { $a <=> $b }(keys %pkeys)) {
	if ($bkey) {$bkey = $bkey.".".$pkeys{$id}};
	if (!$bkey) {$bkey = $pkeys{$id}};
	push(@ekey,$tab1[$id]);
	}
}

sub build_compute_key {
        my @tab1 = @_;
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
        	my $bckey='';
        	my @eckey=();
    		for my $j ( sort { $a <=> $b } (keys %{ $array_of_ckeys_description[$i] }) ) {
		($bckey)?($bckey = $bckey.".".$array_of_ckeys_description[$i]{$j}):($bckey = $array_of_ckeys_description[$i]{$j});
		push(@eckey,$tab1[$j]);
    		}
	my $ckey = sprintf($bckey,@eckey);
	$array_of_ckey[$i]=$ckey;
	}	
}

sub initialise_arrays { 
	$sql1 = $dbh->prepare($main_sql);
	my $key;
	$sql1->execute;
	while ( my @tab1 = $sql1->fetchrow_array) {
	&build_the_key(@tab1); 
	$key = sprintf($bkey,@ekey);
	@{$rtvalues{$key}}=@tab1;
	@{$diffsnaps{$key}}=@tab1;
	debug("key is : ".$key);
	}
}

sub launch_loop {
	my $key;
	my $ckey;
	for (my $nb=0;$nb < $count;$nb++) {
	print "............................\n";
	print "Collecting $interval sec....\n";
	print "............................\n";
	sleep $interval;
	$sql1->execute;
	($seconds, $minuts, $hours) = localtime(time);
	# Empty diffsnaps
	%diffsnaps = ();
	while ( my @tab1 = $sql1->fetchrow_array) {
	&build_the_key(@tab1);
	$key = sprintf($bkey,@ekey);

	# Is there a compute key ?

	if(@array_of_ckeys_description){
	&build_compute_key(@tab1);
	} else 
	{
        $ckey=$key;
        }		

	# Initialise non delta fields
	for (my $tabid=0;$tabid < scalar(@tab1);$tabid++) {
	if(@array_of_ckeys_description){
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
	my $ckey=$array_of_ckey[$i];
	$diffsnaps{$ckey}->[$tabid]=($array_of_display_keys[$i]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
	debug("Non delta fields: for display_keys $array_of_display_keys[$i]{$tabid} and tabid $tabid ".$diffsnaps{$ckey}->[$tabid]);
	}
	}
	else
	{
	$diffsnaps{$ckey}->[$tabid]=($array_of_display_keys[0]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
	debug("Non delta fields: for display_keys $array_of_display_keys[0]{$tabid}} and tabid $tabid ".$diffsnaps{$ckey}->[$tabid]);
	}
	}
 
	# get the list of delta fields
        foreach my $deltaid (@delta_fields) {
	if(@array_of_ckeys_description){
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
	my $ckey=$array_of_ckey[$i];
        debug("deltaid : ".$deltaid);
        $diffsnaps{$ckey}->[$deltaid] = $diffsnaps{$ckey}->[$deltaid] + $tab1[$deltaid] - $rtvalues{$key}->[$deltaid];
        debug("Previous : ".$rtvalues{$key}->[$deltaid]);
        debug("Current : ".$tab1[$deltaid]);
        debug("Diff is : ".$diffsnaps{$ckey}->[$deltaid]);
	}
	} else {
        $diffsnaps{$ckey}->[$deltaid] = $diffsnaps{$ckey}->[$deltaid] + $tab1[$deltaid] - $rtvalues{$key}->[$deltaid];
	}
        }
        @{$rtvalues{$key}} = @tab1;
        debug("key is : ".$key);
        debug("ckey is : ".$ckey);
        }	
	# Report now
	&report_header;
	&report_values;
	}
}

sub report_header {
	foreach my $report_ligne (0..@array_of_report_header-1) {
		my @header=($hours,$minuts,$seconds);
		foreach my $report_column (1..@{$array_of_report_header[$report_ligne]}) {
	        push(@header,$array_of_report_header[$report_ligne][$report_column]);
		}
		printf ($array_of_report_header[$report_ligne][0],@header);
	}
}

sub report_resultset {

	my $pk=shift;
	my %resultset=@_;

	my @values = ($hours,$minuts,$seconds);
	if (%showinstances) {push(@values,'',$showinstances{$resultset{$pk}->[0]})};
	if (%asm_dg) {push(@values,'',$asm_dg{$resultset{$pk}->[1]})};

	foreach my $id (@report_fields_values) {

	push(@values,'');

	my @need_div=split(/\//,$id);
	my @need_mult=split(/\*/,$id);

	if (@need_mult > 1) {
	$need_mult[1] =~ s/\/.*//;
	$resultset{$pk}->[$need_mult[0]] = ($resultset{$pk}->[$need_mult[0]]) * $need_mult[1];
	debug("Mult is needed for id : ".$id);
	debug("Mult[0] is : ".$need_mult[0]);
	debug("Mult[1] is : ".$need_mult[1]);
	} 

	if (@need_div > 1) {
	$need_div[0] =~ s/\*.*//;
	debug("Div is needed for id : ".$id);
	debug("div[0] is : ".$need_div[0]);
	debug("div[1] is : ".$need_div[1]);
	if (@need_div==3) {
	if ($resultset{$pk}->[$need_div[1]] > 0) {push(@values,$resultset{$pk}->[$need_div[0]]/$need_div[2]/$resultset{$pk}->[$need_div[1]])};
	if ($resultset{$pk}->[$need_div[1]] == 0) {push(@values,0)};
	}
	if (@need_div==2) {
	if ($resultset{$pk}->[$need_div[1]] > 0) {push(@values,$resultset{$pk}->[$need_div[0]]/$resultset{$pk}->[$need_div[1]])};
	if ($resultset{$pk}->[$need_div[1]] == 0) {push(@values,0)};
	}
	}
	else
	{
	push(@values,$resultset{$pk}->[$id]);
	}
	}
	printf ($report_format_values,@values);
}

sub report_values {
	my $nb =1;
	my %resultset = ();

	if ($sort_field_pattern)
	{
	# Sort descending and keep the topn first rows

	foreach my $pk (sort {$diffsnaps{$b}[$sort_fields{uc($sort_field_pattern)}] <=> $diffsnaps{$a}[$sort_fields{uc($sort_field_pattern)}] } (keys(%diffsnaps))) {

                if ($nb <= $topn )
                {
                $nb=$nb+1;
                @{$resultset{$pk}}=@{$diffsnaps{$pk}};
                }

                # Break the foreach
                last if ($nb > $topn);
        }

	# Display the topn rows in ascending order by value
	foreach my $pk (sort {$resultset{$a}[$sort_fields{uc($sort_field_pattern)}] <=> $resultset{$b}[$sort_fields{uc($sort_field_pattern)}] } (keys(%resultset))) {
	&report_resultset($pk,%resultset);
	}	
	}
	else
	{	
	foreach my $pk (reverse sort (keys(%diffsnaps))) {
	&report_resultset($pk,%diffsnaps);
	}
	}
}


sub usage {

# Main Usage
if (!$real_time_type) {&usage_global()};;

# Usage for sysstat
if ($real_time_type =~ m/^sysstat$/i ) {&usage_sysstat()};

# Usage for system_event 
if ($real_time_type =~ m/^system_event$/i ) {&usage_system_event()};

# Usage for event_histogram
if ($real_time_type =~ m/^event_histogram$/i ) {&usage_event_histogram()};

# Usage for sgastat
if ($real_time_type =~ m/^sgastat$/i ) {&usage_sgastat()};

# Usage for enqueue_statistics
if ($real_time_type =~ m/^enqueue_statistics$/i ) {&usage_enqueue_statistics()};

# Usage for librarycache
if ($real_time_type =~ m/^librarycache$/i ) {&usage_librarycache()};

# Usage for segments_stats
if ($real_time_type =~ m/^segments_stats$/i ) {&usage_segments_stats()};

# Usage for sess_event
if ($real_time_type =~ m/^sess_event$/i ) {&usage_sess_event()};

# Usage for sess_stat
if ($real_time_type =~ m/^sess_stat$/i ) {&usage_sess_stat()};

# Usage for asmiostat
if ($real_time_type =~ m/^asmiostat$/i ) {&usage_asmiostat()};

}


sub usage_global {

print " \nUsage: $0 [-interval] [-count] [-type] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-30s %-100s \n",'Parameter','Value','Comment');
printf ("  %-15s   %-30s %-100s \n",'---------','-------','-------');
printf ("  %-15s   %-30s %-100s \n",'-type','sysstat','Real-Time snaps extracted from gv$sysstat');
printf ("  %-15s   %-30s %-100s \n",'','system_event','Real-Time snaps extracted from gv$system_event');
printf ("  %-15s   %-30s %-100s \n",'','event_histogram','Real-Time snaps extracted from gv$event_histogram');
printf ("  %-15s   %-30s %-100s \n",'','sgastat','Real-Time snaps extracted from gv$sgastat');
printf ("  %-15s   %-30s %-100s \n",'','enqueue_statistics','Real-Time snaps extracted from gv$enqueue_statistics');
printf ("  %-15s   %-30s %-100s \n",'','librarycache','Real-Time snaps extracted from gv$librarycache');
printf ("  %-15s   %-30s %-100s \n",'','segments_stats','Real-Time snaps extracted from gv$segstat');
printf ("  %-15s   %-30s %-100s \n",'','sess_event','Real-Time snaps extracted from gv$session_event and gv$session');
printf ("  %-15s   %-30s %-100s \n",'','sess_stat','Real-Time snaps extracted from gv$sesstat and gv$session');
printf ("  %-15s   %-30s %-100s \n",'','asmiostat','Real-Time snaps extracted from gv$asm_disk_stat');
print ("\n");
printf ("  %-15s   %-30s %-100s \n",'-help','Print the main help or related to a type (if not empty)','');
print ("\n");
printf ("  %-15s\n",'Description:');
printf ("  %-15s\n",'-----------');
print ("  Utility used to display real time informations based on cumulative views\n");
print ("  It basically takes a snapshot each second (default interval) of the cumulative view and computes the differences\n");
print ("  with the previous snapshot\n");
print ("  It is oracle RAC aware: you can work on all the instances, a subset or the local one\n");
print ("  You have to set oraenv on one instance of the database you want to diagnose first\n");
print ("  You can choose the number of snapshots to display and the time to wait between snapshots\n");
print ("\n");
print ("Example: $0 -type=sysstat -help\n");
print ("Example: $0 -type=system_event -help\n");
print "\n\n";
exit 1;
} 


sub usage_sysstat {

print " \nUsage: $0 -type=sysstat [-interval] [-count] [-inst] [-top] [-statname] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-15s   %-60s %-10s \n",'-STATNAME=','ALL - Show all STATS (wildcard allowed)','ALL');
print ("\n");
print ("Example: $0 -type=sysstat\n");
print ("Example: $0 -type=sysstat -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=sysstat -statname='bytes sent via SQL*Net to client'\n");
print ("Example: $0 -type=sysstat -statname='%bytes%'\n");
print "\n\n";
exit 1; 
}

sub usage_sess_stat {

print " \nUsage: $0 -type=sess_stat [-interval] [-count] [-inst] [-top] [-statname] [-sid] [-sql_id] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-15s   %-60s %-10s \n",'-STATNAME=','ALL - Show all STATS (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-SID=','ALL - STAT Agregated for all SID ','ALL');
printf ("  %-15s   %-60s %-10s \n",'-SQL_ID=','ALL - Show all sql_id','ALL');
print ("\n");
print ("Example: $0 -type=sess_stat\n");
print ("Example: $0 -type=sess_stat -sid=160\n");
print ("Example: $0 -type=sess_stat -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=sess_stat -statname='bytes sent via SQL*Net to client'\n");
print ("Example: $0 -type=sess_stat -statname='%bytes%' -sid=115\n");
print "\n\n";
exit 1;
}

sub usage_sgastat {

print " \nUsage: $0 -type=sgastat [-interval] [-count] [-inst] [-top] [-pool] [-name] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-10s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-10s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-10s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-10s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-10s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-10s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-10s   %-60s %-10s \n",'-POOL=','ALL - Show all POOL (wildcard allowed)','ALL');
printf ("  %-10s   %-60s %-10s \n",'-NAME=','ALL - Show all NAME (wildcard allowed)','ALL');
print ("\n");
print ("Example: $0 -type=sgastat\n");
print ("Example: $0 -type=sgastat -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=sgastat -pool='%shared%'\n");
print ("Example: $0 -type=sgastat -name='%free%'\n");
print ("Example: $0 -type=sgastat -pool='%shared%' -name='%free%'\n");
print "\n\n";
exit 1;
}

sub usage_asmiostat {

print " \nUsage: $0 -type=asmiostat [-interval] [-count] [-inst] [-dg] [-fg] [-ip] [-show] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-10s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-10s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-10s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-10s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-10s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-10s   %-60s %-10s \n",'-DG=','Diskgroup to collect (comma separated list)','ALL');
printf ("  %-10s   %-60s %-10s \n",'-FG=','Failgroup to collect (comma separated list)','ALL');
printf ("  %-10s   %-60s %-10s \n",'-IP=','IP (Exadata Cells) to collect (Wildcard allowed)','ALL');
printf ("  %-10s   %-60s %-10s \n",'-SHOW=','What to show: inst,fg|ip,dg,dsk (comma separated list)','DG');
print ("\n");
print ("Example: $0 -type=asmiostat\n");
print ("Example: $0 -type=asmiostat -inst=+ASM1\n");
print ("Example: $0 -type=asmiostat -dg=DATA -show=dg\n");
print ("Example: $0 -type=asmiostat -dg=data -show=inst,dg,fg\n");
print ("Example: $0 -type=asmiostat -show=dg,dsk\n");
print ("Example: $0 -type=asmiostat -show=inst,dg,fg,dsk\n");
print ("Example: $0 -type=asmiostat -show=ip -ip='%10%'\n");
print "\n\n";
exit 1;
}

sub usage_event_histogram {

print " \nUsage: $0 -type=event_histogram [-interval] [-count] [-inst] [-top] [-event] [-sort_field] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-15s   %-60s %-10s \n",'-EVENT=','ALL - Show all EVENTS (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-SORT_FIELD=','WAIT_TIME_MS|COUNT','COUNT');
print ("\n");
print ("Example: $0 -type=event_histogram\n");
print ("Example: $0 -type=event_histogram -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=event_histogram -event='direct path read temp'\n");
print ("Example: $0 -type=event_histogram -event='%file%'\n");
print ("Example: $0 -type=event_histogram -sort_field=WAIT_TIME_MS\n");
print "\n\n";
exit 1;
}

sub usage_librarycache {

print " \nUsage: $0 -type=librarycache [-interval] [-count] [-inst] [-top] [-namespace] [-sort_field] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-12s   %-65s %-10s \n",'Parameter','Comment','Default');
printf ("  %-12s   %-65s %-10s \n",'---------','-------','-------');
printf ("  %-12s   %-65s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-12s   %-65s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-12s   %-65s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-12s   %-65s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-12s   %-65s %-10s \n",'-NAMESPACE=','ALL - Show all NAMESPACE (wildcard allowed)','ALL');
printf ("  %-12s   %-65s %-10s \n",'-SORT_FIELD=','RELOADS|INVALIDATIONS|GETS|PINS','GETS');
print ("\n");
print ("Example: $0 -type=librarycache\n");
print ("Example: $0 -type=librarycache -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=librarycache -sort_field='PINS'\n");
print ("Example: $0 -type=librarycache -namespace='%TRI%'\n");
print "\n\n";
exit 1;
}

sub usage_sess_event {

print " \nUsage: $0 -type=sess_event [-interval] [-count] [-inst] [-top] [-event] [-sid] [-sql_id] [-sort_field] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-12s   %-65s %-10s \n",'Parameter','Comment','Default');
printf ("  %-12s   %-65s %-10s \n",'---------','-------','-------');
printf ("  %-12s   %-65s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-12s   %-65s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-12s   %-65s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-12s   %-65s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-12s   %-65s %-10s \n",'-EVENT=','ALL - Show all EVENTS (wildcard allowed)','ALL');
printf ("  %-12s   %-65s %-10s \n",'-SID=','ALL - EVENT Agregated for all SID','ALL');
printf ("  %-12s   %-65s %-10s \n",'-SQL_ID=','ALL - Show all SQL_ID','ALL');
printf ("  %-12s   %-65s %-10s \n",'-SORT_FIELD=','NB_WAITS|TIME_WAITED_MICRO','NB_WAITS');
print ("\n");
print ("Example: $0 -type=sess_event\n");
print ("Example: $0 -type=sess_event -sid=160\n");
print ("Example: $0 -type=sess_event -SORT_FIELD=TIME_WAITED_MICRO\n");
print ("Example: $0 -type=sess_event -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=sess_event -event='direct path read temp'\n");
print ("Example: $0 -type=sess_event -event='%file%' sid=195\n");
print "\n\n";
exit 1;
}

sub usage_segments_stats {

print " \nUsage: $0 -type=segments_stats [-interval] [-count] [-inst] [-top] [-owner] [-segment] [-statname] [-include_sys] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-15s   %-60s %-10s \n",'-OWNER=','ALL - Show all OWNER','ALL');
printf ("  %-15s   %-60s %-10s \n",'-SEGMENT=','ALL - Show all SEGMENTS (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-STATNAME=','ALL - Show all Stats (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-INCLUDE_SYS=','Show SYS OBJECTS','N');
print ("\n");
print ("Example: $0 -type=segments_stats\n");
print ("Example: $0 -type=segments_stats -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=segments_stats -segment='AQ%' -statname='physical%'\n");
print ("Example: $0 -type=segments_stats -segment='AQ%' -statname='physical writes direct'\n");
print "\n\n";
exit 1;
}

sub usage_enqueue_statistics {

print " \nUsage: $0 -type=enqueue_statistics [-interval] [-count] [-inst] [-top] [-eq_name] [-eq_type] [-req_reason] [-sort_field] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-60s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-60s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-60s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-60s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-60s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-60s %-10s \n",'-TOP=','Number of rows to display','10');
printf ("  %-15s   %-60s %-10s \n",'-EQ_NAME=','ALL - Show all ENQ NAME (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-EQ_TYPE=','ALL - Show all ENQ TYPE (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-REQ_REASON=','ALL - Show all REASONS (wildcard allowed)','ALL');
printf ("  %-15s   %-60s %-10s \n",'-SORT_FIELD=','TOTAL_REQ|TOTAL_WAIT|SUCC_REQ|FAILED_REQ|WAIT_TIME','TOTAL_REQ');
print ("\n");
print ("Example: $0 -type=enqueue_statistics\n");
print ("Example: $0 -type=enqueue_statistics -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=enqueue_statistics -sort_field=WAIT_TIME\n");
print ("Example: $0 -type=enqueue_statistics -eq_name='%sactio%'\n");
print ("Example: $0 -type=enqueue_statistics -req_reason='contention'\n");
print "\n\n";
exit 1;
}

sub usage_system_event {

&connect_db;
my $sqlwait_class = $dbh->prepare('select distinct(WAIT_CLASS) from v$system_event');
my $wait_class_list;

$sqlwait_class->execute;
my $wait_id=0;
while ( my ($wait_class) = $sqlwait_class->fetchrow_array) {
$wait_class_list = $wait_class_list."|".$wait_class;
}
# Supress first |
$wait_class_list =~ s/^\|// ;

print " \nUsage: $0 -type=system_event [-interval] [-count] [-inst] [-top] [-waitclass] [-event] [-sort_field] [-help]\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-107s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-107s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-107s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-107s %-10s \n",'','CURRENT - Show Current Instance ','');
printf ("  %-15s   %-107s %-10s \n\n",'','INSTANCE_NAME,... - choose Instance(s) to display ','');
printf ("  %-15s   %-107s %-10s \n",'-TOP=','Number of rows to display ','10');
printf ("  %-15s   %-107s %-10s \n",'-WAITCLASS=',$wait_class_list,'ALL');
printf ("  %-15s   %-107s %-10s \n",'-EVENT=','ALL - Show all EVENTS (wilcard allowed)','ALL');
printf ("  %-15s   %-107s %-10s \n",'-SORT_FIELD=','NB_WAITS|TIME_WAITED_MICRO','NB_WAITS');
print ("\n");
print ("Example: $0 -type=system_event\n");
print ("Example: $0 -type=system_event -inst=BDTO_1,BDTO_2\n");
print ("Example: $0 -type=system_event -sort_field=TIME_WAITED_MICRO\n");
print ("Example: $0 -type=system_event -waitclass='User I/O'\n");
print ("Example: $0 -type=system_event -event='%file%'\n");
print "\n\n";
exit 1;
}

sub debug {
    if ($debug==1) {
        print $_[0]."\n";
    }
}


&main(@ARGV);

