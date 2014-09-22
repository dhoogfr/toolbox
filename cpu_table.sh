#!/bin/bash

gawk '
BEGIN { 
  FS = ":" 
  printf "%5-s %6-s %4-s\n", "OS ID", "Socket", "Core"
  printf "%5-s %6-s %4-s\n", "-----", "------", "----"
} 
{ 
  if ($1 ~ /processor/) {
    PROC = $2 
  } else if ($1 ~ /physical id/) {
      PHYID = $2
    }  else if ($1 ~ /core id/) { 
         CID = $2
         printf "%5s %6s %4s\n", PROC, PHYID, CID
      } 
}' /proc/cpuinfo
