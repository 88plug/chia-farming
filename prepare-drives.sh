#VERY DANGEROUS SCRIPT

count=0
for drive in /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1 /dev/sdi1 /dev/sdj1 /dev/sdk1 /dev/sdl1
do
    count=$((count+1))
    echo "Working on $drive | Going NUCLEAR"
    sleep 10
    echo "Last chance..."
    sleep 5
    sudo mkfs.ext4 -L chia-"x"${count} -b 4096 $drive
    sudo tune2fs -m 0 $drive #0% reserve
    sudo hdparm -W 0 $drive #Disable write-cache
    sudo udisksctl power-off -b $drive #Power off to finalize hdparm commands.
done

#    sudo tune2fs -O ^has_journal -i 0 $drive #Removed unless drive used for Farming Node.
