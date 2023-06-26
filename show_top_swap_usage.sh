#!/bin/bash

# get the top 10 processes consuming swap space (in KB)
for file in /proc/*/status ; do awk '/VmSwap|Name|^Pid:/ { printf $2 " " $4 " " $6 } END { print ""}' $file; done | sort -k 3 -n -r | head -10
