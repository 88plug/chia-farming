#!/bin/bash

#VERY DANGEROUS SCRIPT
rm fstab-entries
rm failing_drives.log

count=0
for drive in /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1 /dev/sdi1 /dev/sdj1 /dev/sdk1 /dev/sdl1
do
    count=$((count+1))
    echo "Working on $drive | Going NUCLEAR"
    #Wipe signatures first // without this ZFS drives blocked
    wipefs --force --all $drive
    #####
    #HAIL MARY OPTION like bad superblock or protection layer2
    #screen -dmS format sg_format --format --fmtpinfo=0 /dev/$drive
    #####
    serial=$(smartctl -i $drive | grep -i "Serial Number" | awk -F ': +' '{print $2}')
    vendor=$(smartctl -i $drive | grep -i "Vendor" | awk '{print $2}')
    product=$(smartctl -i $drive | grep -i "Product" | awk '{print $2}')
    echo "----- Formatting : $vendor | $product | $serial -----"
    mkfs.ext4 -F -L chia-${serial: -4}-"x"${count} -T largefile -O ^has_journal $drive
    tune2fs -m 0 $drive #0% reserve
    hdparm -W 0 $drive #Disable write-cache
    echo "LABEL=chia-${serial: -4}-x${count} /mnt/chia ext4 noatime,nodiratime,nofail,x-systemd.device-timeout=10 0 0" >> fstab-entries
    mount_point="/mnt/chia-${serial: -4}-x${count}"
    mkdir -p $mount_point
    if mount -t ext4 $drive $mount_point; then
        if touch $mount_point/temp_file; then
            echo "SUCCESS on $drive"
            rm -f $mount_point/temp_file
            umount $drive
        else
            echo "Failed to write to $drive"
            echo "$vendor | $product | $serial" >> failing_drives.log
            umount $drive
        fi
    else
        echo "$vendor | $product | $serial_2 | $serial" >> failing_drives.log
        echo "Failed to mount $drive"
    fi
    rmdir $mount_point #remove the mount point directory

done
echo "Check after you run the script in Proxmox for drives to present - any that do not have an ext4 partition are FAILED!"
