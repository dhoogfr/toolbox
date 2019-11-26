#!/usr/bin/env bash

### sets the short and long retention policy for all oracle homes
### and issues a purge for all non rdbms homes (smon automatically runs a purge once every 7 days)
###
### run as Oracle owner, expects no role separation between Oracle and GI
### advice to schedule this once a week
###
### adrci_cleanup.sh [ORACLE_HOME] [adrci base] [short policy duration] [long policy duration] 


export ORACLE_HOME=${1:-/u01/app/oracle/product/18.0.0.0/dbhome_1}
ADRCI=${ORACLE_HOME}/bin/adrci
adrci_base=${2:-/u01/app/oracle}
#short: script default 7 days, used for TRACE, CDUMP, UTSCDMP, IPS
shortp_policy=${3:-168}
#long: script default 31 days, used for ALERT, INCIDENT, SWEEP, STAGE, HM
longp_policy=${4:-744}

### loops through the adrci homes and sets the short and long policy
echo
echo set policies
echo using ${adrci_base} as adrci_bash
echo
for home in $(${ADRCI} exec="set base ${adrci_base}; show homes" | egrep -e "/rdbms/|/tnslsnr/|/asm/")
do
  echo set policy for ${home}
  ${ADRCI} exec="set homepath ${home}; set control \(SHORTP_POLICY = ${shortp_policy}, LONGP_POLICY = ${longp_policy}\)"
done


### loop through the non database homes and issue the purge (db homes are done by smon automatically every 7 days)
###  ---> changed to do rdbms homes as wel due to bug 29021413  (see MOS Note Doc ID 2572977.1 - ADR Files are not purged automatically) 
echo
echo purging non rdbms homes
echo using ${adrci_base} as adrci_bash
echo
start=$SECONDS
for home in $(${ADRCI} exec="set base ${adrci_base}; show homes" | egrep -e "/rdbms/|/tnslsnr/|/asm/")
do
  echo Purging home ${home}
  homestart=$SECONDS
  ${ADRCI} exec="set homepath ${home}; purge"
  echo Duration: $(date -u -d "0 $SECONDS sec - ${homestart} sec" +"%H:%M:%S")
  echo
done
echo Total duration: $(date -u -d "0 $SECONDS sec - ${start} sec" +"%H:%M:%S")

