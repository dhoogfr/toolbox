#!/bin/bash

### still have to add the code to check the script is executed as root
ls -1 /sys/class/fc_transport/ | tr -d [[:alpha:]] | awk -v lun_id=$1 'BEGIN {FS=":"} {system("echo \""$2 " " $3 " " lun_id "\" > /sys/class/scsi_host/host"$1"/scan")}'
