#!/bin/bash

CLIENT=$1 ; shift
DB=$1 ; shift
FILE_LIST=$@
for FILE in $FILE_LIST
do
  awk 'BEGIN {printf "%-19s", "File:"}'; echo $FILE;
  for BACKUP_ID in `bpflist -d 01/01/1970 00:00:00 -pt Oracle -pattern $FILE -client $CLIENT -keyword $DB -U | grep "Backup ID:" |awk '{print $3}'`
  do
    bpimagelist -media -backupid $BACKUP_ID -L | egrep "Backup ID:|Backup Time:|Copy number:|Fragment:|Media Type:|Expiration Time:|^[ ]*ID";
  done
  echo
done
