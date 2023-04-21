#!/bin/bash

#VERY DANGEROUS SCRIPT
#First find drives > 1TB with : lsblk -d -o name,size | grep -E '[[:space:]]+[1-9][0-9]*\.[0-9]*T$' | awk '{ printf("/dev/%s ", $1) }'
#Replace the drives in the for loop with the results

rm fstab-entries
rm failing_drives.log

count=0
for drive in /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1 /dev/sdi1 /dev/sdj1 /dev/sdk1 /dev/sdl1
do
    count=$((count+1))
    echo "Working on $drive | Going NUCLEAR"
    dd if=/dev/zero of=$drive bs=512 count=1 conv=notrunc #remove header
    wipefs --force --all $drive
    #####
    #HAIL MARY OPTION like bad superblock or protection layer2
    #screen -dmS format sg_format --format --fmtpinfo=0 /dev/$drive
    #####
    serial=$(smartctl -i $drive | grep -i "Serial Number" | awk -F ': +' '{print $2}')
    vendor=$(smartctl -i $drive | grep -i "Vendor" | awk '{print $2}')
    product=$(smartctl -i $drive | grep -i "Product" | awk '{print $2}')
    echo "----- Formatting : $vendor | $product | $serial -----"
    parted -a optimal $drive --script mklabel gpt mkpart primary ext4 0% 100% name 1 chia-${serial: -4}-"x"${count}
    part="$drive""1"
    mkfs.ext4 -F -U $(uuidgen) -L chia-${serial: -4}-"x"${count} $part
    tune2fs -m 0 $part #0% reserve
    hdparm -W 0 $part #Disable write-cache
    uuid=$(blkid -s UUID -o value $part)
    echo "UUID=$uuid /mnt/chia-$count ext4 noatime,nodiratime,nofail,x-systemd.device-timeout=10 0 0" >> fstab-entries
    mount_point="/mnt/chia-$count"
    mkdir -p $mount_point
    if mount -t ext4 $part $mount_point; then
        if touch $mount_point/temp_file; then
            echo "SUCCESS on $part"
            rm -f $mount_point/temp_file
            umount $part
        else
            echo "Failed to write to $part"
            echo "$vendor | $product | $serial" >> failing_drives.log
            umount $part
        fi
    else
        echo "$vendor | $product | $serial_2 | $serial" >> failing_drives.log
        echo "Failed to mount $part"
    fi
    rmdir $mount_point #remove the mount point directory
done
echo "Check after you run the script in Proxmox for drives to present - any that do not have an ext4 partition are FAILED!"
