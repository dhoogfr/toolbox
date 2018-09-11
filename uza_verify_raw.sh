#!/bin/bash
OLSNODES=/opt/crs/bin/olsnodes
KFED=/opt/oracle/product/10.2.0/asm/bin/kfed
hformat="%-10s %-15s %-30s %-65s %-15s %-15s\n"
dformat="%-10s %-15s %-30s %-65s %-15s %-15s\n"

rw=$1

echo
echo RAW Device: $rw
echo
printf "$hformat" "server" "emc device" "san info" "emc info" "kfed diskgroup" "kfed failgroup"
printf "$hformat" "----------" "---------------" "------------------------------" "-----------------------------------------------------------------" "---------------" "---------------"
for srv in `$OLSNODES`
do
  ### for some reason I could not get \b to work with grep when called over ssh
  emcpart=`ssh $srv grep "$rw[[:space:]]" /etc/sysconfig/rawdevices | grep -v '^#' | tr "\t" " " | tr -s " " | cut -d' ' -f2 | cut -d'/' -f3`
  emc=`echo $emcpart | tr -d [0-9]`
  emcinfo=`ssh $srv sudo /sbin/powermt display dev=$emc | grep "Logical device" | cut -d' ' -f3,4`
  saninfo=`ssh $srv sudo /sbin/powermt display dev=$emc | egrep -i "clariion|ess|hitachi|hphsx|hpxp|invista|symm" | tr -s " " | cut -d' ' -f1,2`
  grpname=`ssh $srv $KFED read /dev/raw/$rw | grep grpname | cut -d':' -f2 | cut -d';' -f1 | tr -d ' '`
  fgname=`ssh $srv $KFED read /dev/raw/$rw | grep fgname | cut -d':' -f2 | cut -d';' -f1 | tr -d ' '`
  printf "$dformat" "$srv" "$emcpart" "$saninfo" "$emcinfo" "$grpname" "$fgname"
done
