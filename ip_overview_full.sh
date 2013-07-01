#!/bin/bash

IFCONFIG=/sbin/ifconfig
ROUTE=/sbin/route

echo
echo "Interfaces"
echo "----------"
echo

${IFCONFIG} -a | awk '
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

${IFCONFIG} -a | awk '
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
echo "modprobe.conf"
echo "-------------"

if [ -r /etc/modprobe.conf ]
then
  cat /etc/modprobe.conf
elif [ -r /etc/modprobe.d/bonding.conf ]  ### new Redhat / OL 6 specification
then
  cat /etc/modprobe.d/bonding.conf
fi

echo
echo "Routing table"
echo "-------------"
echo

${ROUTE} -n


echo
echo "Network"
echo "-------"
echo

cat /etc/sysconfig/network

echo
echo "/etc/hosts"
echo "----------"
echo

cat /etc/hosts

echo
echo "Names servers"
echo "-------------"
echo

cat /etc/resolv.conf

echo
echo "Network Scripts"
echo "---------------"
echo

cd /etc/sysconfig/network-scripts/
for i in `ls -1 ifcfg-*` ; do echo $i; cat $i; echo ; done

