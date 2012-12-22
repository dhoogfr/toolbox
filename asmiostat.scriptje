#!/bin/ksh
#
# NAME
#   asmiostat.sh
# 
# DESCRIPTION
#   iostat-like output for ASM
#   $ asmiostat.sh [-s ASM ORACLE_SID] [-h ASM ORACLE_HOME] [-g Diskgroup]
#                  [-f disk path filter] [<interval>] [<count>]
#
# NOTES
#   Creates persistent SQL*Plus connection to the +ASM instance implemented
#   as a ksh co-process
#
# AUTHOR
#   Doug Utzig
#
# MODIFIED
#   dutzig    08/18/05 - original version
#

ORACLE_SID=+ASM

NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

endOfOutput="_EOP$$"

typeset -u diskgroup
typeset diskgroup_string="Disk Group: All diskgroups"
typeset usage="
$0 [-s ASM ORACLE_SID] [-h ASM ORACLE_HOME] [-g diskgroup] [<interval>] [<count>]

Output:
  DiskPath - Path to ASM disk
  DiskName - ASM disk name
  Gr       - ASM disk group number
  Dsk      - ASM disk number
  Reads    - Reads 
  Writes   - Writes 
  AvRdTm   - Average read time (in msec)
  AvWrTm   - Average write time (in msec)
  KBRd     - Kilobytes read
  KBWr     - Kilobytes written
  AvRdSz   - Average read size (in bytes)
  AvWrSz   - Average write size (in bytes)
  RdEr     - Read errors
  WrEr     - Write errors
"

while getopts ":s:h:g:f" option; do
  case $option in
    s)  ORACLE_SID="$OPTARG" ;;
    h)  ORACLE_HOME="$OPTARG"
        LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH ;;
    g)  diskgroup="$OPTARG"
        diskgroup_string="Disk Group: $diskgroup" ;;
    f)  print '-f option not implemented' ;;
    :)  print "Option $OPTARG needs a value"
        print "$usage"
        exit 1 ;;
    \?) print "Invalid option $OPTARG"
        print "$usage"
        exit 1 ;;
  esac
done
shift OPTIND-1

typeset -i interval=${1:-10} count=${2:-0} index=0

#
# Verify interval and count arguments are valid
#
(( interval <=0 || count<0 )) && {
  print 'Invalid parameter: <interval> must be > 0; <count> must be >= 0'
  print "$usage"
  exit 1
}

#
# Query to run against v$asm_disk_stat
#
if [[ -z $diskgroup ]]; then
  query="select group_number, disk_number, name, path, reads, writes, read_errs, write_errs, read_time, write_time, bytes_read, bytes_written from v\$asm_disk_stat where group_number>0 order by group_number, disk_number;"
else
  query="select group_number, disk_number, name, path, reads, writes, read_errs, write_errs, read_time, write_time, bytes_read, bytes_written from v\$asm_disk_stat where group_number=(select group_number from v\$asm_diskgroup_stat where name=regexp_replace('$diskgroup','^\+','')) order by group_number, disk_number;"
fi

#
# Check for version 10.2 or later
#
typeset version minversion=10.2
version=$($ORACLE_HOME/bin/exp </dev/null 2>&1 | grep "Export: " | sed -e 's/^Export: Release \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
if ! (print "$version<$minversion" | bc >/dev/null 2>&1); then
  print "$0 requires Oracle Database Release $minversion or later"
  exit 1
fi

#############################################################################
#
# Fatal error
#----------------------------------------------------------------------------
function fatalError {
  print -u2 -- "Error: $1"
  exit 1
}

#############################################################################
#
# Drain all of the sqlplus output - stop when we see our well known string
#----------------------------------------------------------------------------
function drainOutput {
  typeset dispose=${1:-'dispose'} output
  while :; do
    read -p output || fatalError 'Read from co-process failed [$0]'
    if [[ $QUERYDEBUG == ON ]]; then print $output; fi
    if [[ $output == $endOfOutput* ]]; then break; fi
    [[ $dispose != 'dispose' ]] && print -- $output
  done
}

#############################################################################
#
# Ensure the instance is running and it is of type ASM
#----------------------------------------------------------------------------
function verifyASMinstance {
  typeset asmcmdPath=$ORACLE_HOME/bin/asmcmd
  [[ ! -x $asmcmdPath ]] && fatalError "Invalid ORACLE_HOME $ORACLE_HOME: $asmcmdPath does not exist"
  $asmcmdPath pwd 2>/dev/null | grep -q '^\+$' || fatalError "$ORACLE_SID is not an ASM instance"
}

#############################################################################
#
# Start the sqlplus coprocess
#----------------------------------------------------------------------------
function startSqlplus {
  # start sqlplus, setup the env
  $ORACLE_HOME/bin/sqlplus -s '/ as sysdba' |&

  print -p 'whenever sqlerror exit failure' \
  && print -p "set pagesize 9999 linesize 9999 feedback off heading off" \
  && print -p "prompt $endOfOutput" \
  || fatalError 'Write to co-process failed (startSqlplus)'
  drainOutput dispose
}


#############################################################################
#############################################################################
# MAIN
#----------------------------------------------------------------------------
verifyASMinstance
startSqlplus

#
# Loop as many times as requested or forever
#
while :; do
  print -p "$query" \
  && print -p "prompt $endOfOutput" \
  || fatalError 'Write to co-process failed (collectData)'
  stats=$(drainOutput keep)

  print -- "$stats\nEOL" 

  index=index+1
  (( count<index && count>0 )) && break

  sleep $interval
done  | \
awk '
BEGIN { firstSample=1
}
/^EOL$/ {
  firstSample=0; firstLine=1
  next
}
{
  path=$4
  if (path ~ /^ *$/) next
  group[path]=$1; disk[path]=$2; name[path]=$3

  reads[path]=$5;      writes[path]=$6
  readErrors[path]=$7; writeErrors[path]=$8
  readTime[path]=$9;   writeTime[path]=$10
  readBytes[path]=$11; writeBytes[path]=$12

  # reads and writes
  readsDiff[path]=reads[path]-readsPrev[path]
  writesDiff[path]=writes[path]-writesPrev[path]

  # read errors and write errors
  readErrorsDiff[path]=readErrors[path]-readErrorsPrev[path]
  writeErrorsDiff[path]=writeErrors[path]-writeErrorsPrev[path]
  
  # read time and write time
  readTimeDiff[path]=readTime[path]-readTimePrev[path]
  writeTimeDiff[path]=writeTime[path]-writeTimePrev[path]

  # average read time and average write time in msec (data provided in csec)
  avgReadTime[path]=0; avgWriteTime[path]=0
  if ( readsDiff[path] ) avgReadTime[path]=(readTimeDiff[path]/readsDiff[path])*1000
  if ( writesDiff[path]) avgWriteTime[path]=(writeTimeDiff[path]/writesDiff[path])*1000

  # bytes and KB read and bytes and KB written
  readBytesDiff[path]=readBytes[path]-readBytesPrev[path]
  writeBytesDiff[path]=writeBytes[path]-writeBytesPrev[path]
  readKb[path]=readBytesDiff[path]/1024
  writeKb[path]=writeBytesDiff[path]/1024

  # average read size and average write size
  avgReadSize[path]=0; avgWriteSize[path]=0
  if ( readsDiff[path] ) avgReadSize[path]=readBytesDiff[path]/readsDiff[path]
  if ( writesDiff[path] ) avgWriteSize[path]=writeBytesDiff[path]/writesDiff[path]
  
  if (!firstSample) {
    if (firstLine) {
      "date" | getline now; close("date")
      printf "\n"
      printf "Date: %s    Interval: %d secs    %s\n\n", now, '"$interval"', "'"$diskgroup_string"'"
      printf "%-40s %2s %3s %8s %8s %6s %6s %8s %8s %7s %7s %4s %4s\n", \
        "DiskPath - DiskName","Gr","Dsk","Reads","Writes","AvRdTm",\
        "AvWrTm","KBRd","KBWr","AvRdSz","AvWrSz", "RdEr", "WrEr"
      firstLine=0
    }
    printf "%-40s %2s %3s %8d %8d %6.1f %6.1f %8d %8d %7d %7d %4d %4d\n", \
      path " - " name[path], group[path], disk[path], \
      readsDiff[path], writesDiff[path], \
      avgReadTime[path], avgWriteTime[path], \
      readKb[path], writeKb[path], \
      avgReadSize[path], avgWriteSize[path], \
      readErrorsDiff[path], writeErrorsDiff[path]
  }

  readsPrev[path]=reads[path];           writesPrev[path]=writes[path]
  readErrorsPrev[path]=readErrors[path]; writeErrorsPrev[path]=writeErrors[path]
  readTimePrev[path]=readTime[path];     writeTimePrev[path]=writeTime[path]
  readBytesPrev[path]=readBytes[path];   writeBytesPrev[path]=writeBytes[path]
}
END {
}
'

exit 0

