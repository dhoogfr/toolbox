#!/usr/bin/env python2

### uses the OVM CLI to give an overview of the physcial disks known by the ovm manager, together with the WWID, size, ... information
### Can be executed from any host which has ssh (port 10000) access to the ovm manager
### When executed, the script will ask for the OVM hostname or ip address and for the admin password

import sys
import re
import paramiko
import getpass

OvmHost=raw_input("OVM hostname or ip address: ")
ovmPwd=getpass.getpass("admin user password: ")

print
print("{lunid:40s} {state:10s} {size:10s} {shareable:10s} {wwid:60s} {lunname:70s}".format(lunid="OVM Lun ID", state="Status", size="Size (GiB)", shareable='Shareable', wwid="WWID", lunname="OVM LUN Name"))
print("{lunid:40s} {state:10s} {size:10s} {shareable:10s} {wwid:60s} {lunname:70s}".format(lunid="---------------------------------------", state="----------", size="----------", shareable="----------", wwid="-----------------------------------------------------------", lunname="---------------------------------------------------------------------"))

client=paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

client.connect(OvmHost, port=10000, username='admin', password=ovmPwd, allow_agent=False,look_for_keys=False)
stdin,stdout,stderr=client.exec_command("list physicaldisk")
PDOutput=stdout.read()

for PDLine in PDOutput.split('\n'):
  if "id:" in PDLine :
    PD = re.split('[:\s+]', PDLine.strip(), maxsplit=4)
    client.connect(OvmHost, port=10000, username='admin', password=ovmPwd, allow_agent=False,look_for_keys=False)
    stdin,stdout,stderr=client.exec_command("show physicaldisk id=" + PD[1])
    PDDetailOutput=stdout.read()
    PDWWID=''
    PDState=''
    PDSize=''
    for PDDetailOutputLine in PDDetailOutput.split('\n'):
      if 'Page83 ID =' in PDDetailOutputLine:
        PDWWID = re.split('=', PDDetailOutputLine.strip())
      if 'State =' in PDDetailOutputLine:
        PDState = re.split('=', PDDetailOutputLine.strip())
      if 'Size (GiB) =' in PDDetailOutputLine:
        PDSize = re.split('=', PDDetailOutputLine.strip())
      if 'Shareable =' in PDDetailOutputLine:
        PDShareable = re.split('=', PDDetailOutputLine.strip())
    print("{lunid:40s} {state:10s} {size:10.2f} {shareable:10s} {wwid:60s} {lunname:70s}".format(lunid=PD[1].strip(), state=PDState[1].strip(), size=float(PDSize[1].strip()), shareable=PDShareable[1].strip(), wwid=PDWWID[1].strip(), lunname=PD[4].strip()))
