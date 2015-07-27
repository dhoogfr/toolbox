#!/bin/bash

### list the netapp lun and the corresponding WWID and serial
### it's ugly but does the trick
### when I have some time, I should convert this to perl

for i in `sanlun lun show | awk '{if (NR > 3) { print $1":"$2}}' | sort -u`
do
  echo $i `sanlun lun show -p $i | grep "Host Device" | awk '{gsub(/[()]/," "); print $3; print $4}'`
done | \
awk '
{ 
  cmd="sanlun lun show "$1" -v | grep \"Serial number\" | sort -u | tr -s \" \" | cut -d\" \" -f5"
  cmd | getline serial
  close(cmd)
  cmd="sanlun lun show -p "$1" | grep \"LUN:\" | tr -s \" \" | cut -d\" \" -f3"
  cmd | getline lunid
  close(cmd)
  printf "%3-s %110-s %25-s %40-s %12-s\n", lunid, $1, $2, $3, serial
}' | sort -n | awk '
BEGIN {
  printf "%3-s %110-s %25-s %40-s %12-s\n", "ID", "LUN", "DM", "WWID", "SERIAL"
  printf "%3-s %110-s %25-s %40-s %12-s\n", "---", "--------------------------------------------------------------------------------------------------------------", "-------------------------", "----------------------------------------", "------------"
}
{
  print $0
}'
