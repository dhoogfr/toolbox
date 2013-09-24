#!/bin/bash

for proc in `ls -1 /proc/*/smaps`; do procnbr=`echo $proc | tr -d '[:alpha:]/'`; grep Swap $proc |awk -v proc=$procnbr 'BEGIN {total=0} {total += $2} END {print proc " " total}'; done | sort -nrk 2  | head -n 10