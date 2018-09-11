#!/bin/bash
#
# findilos - Search a local network segment for iLOs
#            The iLO is the Integrated Lights-Out management processor
#            used on HP ProLiant and BladeSystem servers
#
scriptversion="1.0"
#
# Author: iggy@nachotech.com
#
# Website: http://blog.nachotech.com
#
# Requires: tr sed expr curl nmap
#
# Tested with: Nmap 4.20, curl 7.17.1, RHEL4
#
# Note: Discovery of an iLO is dependent upon the Virtual Media port
#       being set to the default of 17988.  If this has been changed
#       by the iLO administrator, then this script will NOT find it.
#
#       Also, if the iLO XML Reply Data Return has been Disabled by
#       the iLO administrator, this script will not be able to
#       gather any information about the server.  It will still be
#       discovered, but all you will see is its IP address.
#

# GLOBAL VARIABLES

scriptname="findilos"
iloips="/tmp/tmpilos.$$"
iloxml="/tmp/tmpiloxml.$$"
ilohwvers="/tmp/tmpilohwvers.$$"

declare -i ilosfound=0

# FUNCTIONS

function parseiloxml {
  fgrep "$1" $iloxml > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    # tag not found in xml output, return empty string
    parsedstring="N/A"
  else
    # tag was found - now we parse it from the output
    tempstring=$( cat $iloxml | tr -d -c [:print:] | sed "s/^.*<$1>//" | sed "s/<.$1.*//")
    # trim off leading and trailing whitespace
    parsedstring=`expr match "$tempstring" '[ \t]*\(.*[^ \t]\)[ \t]*$'`
  fi
}

function is_installed {
  which $1 > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    printf "\nERROR: %s not installed.\n\n" $1
    exit 255
  fi
}

# MAIN

# check for tools that we depend upon

is_installed tr
is_installed sed
is_installed expr
is_installed curl
is_installed nmap

# check syntax - should have 1 and only 1 parameter on cmdline

if [ $# -ne 1 ]; then
  printf "%s %s ( http://blog.nachotech.com/ )\n" $scriptname $scriptversion
  printf "Usage: %s {target network specification}\n" $scriptname
  printf "TARGET NETWORK SPECIFICATION:\n"
  printf "  Can pass hostnames, IP addresses, networks, etc.\n"
  printf "  Ex: server1.company.com, company.com/24, 192.168.0.1/16, 10.0.0-255.1-254\n"
  printf "EXAMPLE:\n"
  printf "  %s 16.32.64.0/22\n" $scriptname
  exit 255
fi

iprange=$1

# prepare lookup file for iLO hardware versions

cat > $ilohwvers << EOF
iLO-1 shows hw version ASIC:  2
iLO-2 shows hw version ASIC:  7
iLO-3 shows hw version ASIC: 8
i-iLO shows hw version T0
EOF

#
# scan a range of IP addresses looking for an
# open tcp port 17988 (the iLO virtual media port)
#

printf "Scanning..."

nmap -n -P0 -sS -p 17988 -oG - $iprange | fgrep /open/ | awk '{print $2}' > $iloips

printf "\n\n"

#
# open and read the list of IP addresses one at a time
#

exec 3< $iloips

echo "--------------- ------ -------- ------------ -------------------------"
echo "iLO IP Address  iLO HW iLO FW   Server S/N   Server Model"
echo "--------------- ------ -------- ------------ -------------------------"

while read iloip <&3 ; do
  ilosfound=$ilosfound+1
  #
  # attempt to read the xmldata from iLO, no password required
  #
  curl --proxy "" --fail --silent --max-time 3 http://$iloip/xmldata?item=All > $iloxml

  #
  # parse out the Server model (server product name)
  # from the XML output
  #

  parseiloxml SPN;  servermodel=$parsedstring
  parseiloxml SBSN; sernum=$parsedstring
  parseiloxml PN;   ilotype=$parsedstring
  parseiloxml FWRI; ilofirmware=$parsedstring
  parseiloxml HWRI; ilohardware=$parsedstring

  ilohwver=$(grep "$ilohardware" $ilohwvers|awk '{print $1}')
  if [ "$ilohwver" == "" ]; then
    ilohwver="N/A"
  fi

  if [ "$sernum" == "" ]; then
    sernum="N/A"
  fi

  printf "%-15s %-6s %-8s %-12s %s\n" $iloip "$ilohwver" "$ilofirmware" "$sernum" "$servermodel"

done

printf "\n%d iLOs found on network target %s.\n\n" $ilosfound $iprange

rm -f $iloips $iloxml $ilohwvers

exit 0
