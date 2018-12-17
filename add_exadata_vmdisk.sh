#!/bin/bash

### This script will create a new virtual disk using the passed name and size and attaches it on the passed vm guest.
### It also modifies the config file for the guest, so the disk will be attached again after a restart
### The script will do some checking after each step to verify a correct outcome, but will not check upfront if enough disk space is available (still to be added)
###
### This script needs to be executed as root on the dom0 of the server on which the virtual disk needs to be created
### Required parameters are <guest name>, <disk name> and <disk size>
### Do NOT add the img suffix to the disk name
### The disk size needs to be suffixed with the unit (eg 20G, to create a disk of 20 GB)
###
### Important to know is that this script will probably fail if the disk device mappings has "gaps", as it simply counts the number of disk devices for the given vm
### to determine the next free front device

### Get the input parameters
guest_name=$1
disk_name=$2
disk_size=$3

### Check if all mandatory input parameters are given
if [ "${guest_name}" == "" ] || [ "${disk_name}" == "" ] || [ "${disk_size}" == "" ]
then
  echo "usage: $0 guest_name disk_name disk_size"
  echo "guest_name is the name of the virtual guest on which the disk needs to be attached"
  echo "disk_name is the name of the disk to be created \(without the .img suffix\)"
  echo "disk_size is the size of the disk, including the unit \(eg 20G\)"
  exit -1
fi

### generate the array of disk devices
### the current limit of attached devices is 37
drive_array=(xvda xvdb xvdc xvdd xvde xvdf xvdg xvdh xvdi xvdj xvdk xvdl xvdm xvdn xvdo xvdp xvdq xvdr xvds xvdt xvdv xvdw xvdx xvdy xvdz xvdaa xvdab xvdac xvdad xvdae xvdae xvdaf xvdag xvdah xvdai xvdaj xvdak)

### get the uuid of the guest on which the new disk needs to be added
guest_uuid=$(xl list-vm | grep ${guest_name}| tr -d '-' |cut -d' ' -f1)
if [ "${guest_uuid}" == "" ]
then
  echo "could not get guest uuid, pleace check guest name"
  exit -1
fi

### get the number of current attached block devices, as the output also includes a header, this is already the next available slot number
### subtract 1 to compensate for the arrays, which start at 0 and not 1
### also, using xm and not xl here as xl seems to not list the disks that are attached on a running instance (exact reason still to be verified)
next_slot=$(($(xm block-list ${guest_name} | wc -l)-1))
if [ "${next_slot}" == "" ]
then
  echo "could not determine a free slot number, check outcome of xm block list ${guest_name}"
  exit -1
fi

### convert the new slot number to a drive name
next_drive=${drive_array[${next_slot}]}
if [ "${next_drive}" == "" ] || [[ ${next_drive} != xvd* ]]
then
  echo "could not convert ${next_slot} to drive, check the drive_array variable"
  exit -1
fi
echo "the new disk will be known on the vm as /dev/${next_drive}"

### generate a new uuid to be used for the new disk
disk_uuid=$(uuidgen | tr -d '-')
if [ "${disk_uuid}" == "" ]
then
  echo "could not generate a new disk_uuid, check path variable for uuidgen"
  exit -1
fi

### create the virtual disk based upon the input parameters
### check first if the disk not already exists
if [ -e "/EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img" ]
then
  echo "file /EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img already exists, use a different disk name"
  exit -1
fi

### create the disk
echo "creating the disk now"
qemu-img create /EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img ${disk_size}

### check if the disks exists
if [ ! -e "/EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img" ]
then
  echo "file /EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img was not created, check free disk space"
  exit -1
fi
echo "disk has been created"

### create the symbolic link, using the uuid of the vm guest and the newly generated uuid
ln -s /EXAVMIMAGES/GuestImages/${guest_name}/${disk_name}.img /OVS/Repositories/${guest_uuid}/VirtualDisks/${disk_uuid}.img

### check if the symbolic link was correctly created
if [ ! -h "/OVS/Repositories/${guest_uuid}/VirtualDisks/${disk_uuid}.img" ]
then
  echo "could not create symbolic link /OVS/Repositories/${guest_uuid}/VirtualDisks/${disk_uuid}.img"
  exit -1
fi

### attach the block
xm block-attach ${guest_name} file:/OVS/Repositories/${guest_uuid}/VirtualDisks/${disk_uuid}.img /dev/${next_drive} w
result_code=$?
if [ ${result_code} -ne 0 ]
then
  echo "an error occured during the attach of the virtual disk, check console output"
  exit -1
fi

### add the new disk to the vm config file, so it is attached when restarted
### The sed commands searches for a line with the format "disk = [<disk strings>]" and inserts the new disk into it.
### It does this by using grouping and back references (eg \1)
### The first group is "disk = [", the second contains the existing disk strings and the third "]"
### The new string is then inserted between the second and third back reference  
sed -i "s/\(^disk = \[\)\(.*\)\(\]\)/\1\2,\'file:\/OVS\/Repositories\/${guest_uuid}\/VirtualDisks\/${disk_uuid}.img,${next_drive},w\'\3/" /EXAVMIMAGES/GuestImages/${guest_name}/vm.cfg
result_code=$?
if [ ${result_code} -ne 0 ]
then
  echo "an error occured during the modification of the vm config file, check console output"
  exit -1
fi

exit 0
