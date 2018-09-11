#!/usr/bin/bash

_bppllist=/usr/openv/netbackup/bin/admincmd/bppllist
_bpplinfo=/usr/openv/netbackup/bin/admincmd/bpplinfo
_bpplsched=/usr/openv/netbackup/bin/admincmd/bpplsched
_bpplinclude=/usr/openv/netbackup/bin/admincmd/bpplinclude
_bpplclients=/usr/openv/netbackup/bin/admincmd/bpplclients

for i in `$_bppllist | sort`; do
echo;
echo POLICY: $i;
echo -----------------------------------------------------------------------------;echo;
$_bpplinfo $i -U;
echo;
echo CLIENTS:;
echo --------;echo;
$_bpplclients $i -U;
echo;
echo INCLUDE LIST:;
echo -------------;echo;
$_bpplinclude $i -U;
echo;
echo SCHEDULES:;
echo ----------;
$_bpplsched $i -U;
echo ------------------------------------------------------------------------------;
echo;echo;
done
