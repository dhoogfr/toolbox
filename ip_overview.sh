#!/bin/bash

echo
echo "Interfaces"
echo "----------"
echo

ifconfig -a | awk '
BEGIN {
  printf "%10-s %20-s\n", "Interface", "Mac Address"
  printf "%10-s %20-s\n", "----------", "--------------------"
}
{ if ($0 ~ "eth")
    { printf "%10-s %20-s\n", $1,$5
    }
}'

echo
echo "IP Adresses"
echo "-----------"
echo

ifconfig -a | awk '
BEGIN {
  printf "%10-s %15-s %15-s\n", "Interface", "IP Adress", "Mask"
  printf "%10-s %15-s %15-s\n", "----------", "---------------", "---------------"
}
{ if ($0 ~ "Link encap:")
    { interface = $1 }
  if ($0 ~ "inet addr")
    { split($2,addr,":")
      split($4,mask,":")
      printf "%10-s %15-s %15-s\n", interface, addr[2], mask[2] 
    }
}'

echo
echo "Network bonds"
echo "-------------"

cd /proc/net/bonding/
for i in `ls -1 bond*`; do echo;  echo $i; egrep "Bonding Mode|MII Status|Slave Interface" $i; done

echo
echo "Routing table"
echo "-------------"
echo

route -n
