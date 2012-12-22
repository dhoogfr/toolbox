#!/bin/bash
#
export ORACLE_HOME=/opt/oracle/oraglims/product/11.2.0.2/db_1
export ORACLE_SID=glims
SPOOLFILE=${ORACLE_SID}_`date '+%Y%m%d%H%M%S'`_ora04031_monitoring.txt

cd /home/oraglims/uptime
$ORACLE_HOME/bin/sqlplus / as sysdba @/home/oraglims/uptime/ora04031_monitoring.sql ${SPOOLFILE}

mutt -s "${ORACLE_SID} ora-04031 monitoring" -a ${SPOOLFILE} freek.dhooge@uptime.be </dev/null

