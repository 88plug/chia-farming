#!/bin/bash

# Setup for multiple destination drives labeled /mnt/chia-1 to /mnt/chia-72. Adjust as needed below.

# Set the rsync destination
user="root"
destination="192.168.1.50"

# Set the max transfers at any given time / 8 will saturate a 10GB link
max_transfers=8

# Set the source directory where your plots are located
source_dir="/home/andrew/fast-cache/final"

# Set the list of farming drives you want to use
farming_drives=(
)
for i in {1..52}; do
    farming_drives+=("/mnt/chia-$i")
done

##############################DO NOT EDIT BELOW THIS LINE

# Initialize a variable to store the last farming drive used
last_drive=""

# Initialize an array to store the PIDs of transfer processes
pids=()

# Initialize an array to store the names of plot files that have already been moved
moved_files=()

# Initialize an array to store the drives that are currently in use
in_use_drives=()

# Function to check if a farming drive is available for use
function is_drive_available() {
    local drive="$1"

    # Check if the farming drive is currently being used for a transfer
    for pid in "${pids[@]}"
    do
        # Get the destination directory of the transfer
        local dest=$(ps -o cmd= -p "$pid" | grep -o "$drive[^ ]*")
        if [ "$dest" == "$drive" ]; then
            return 1
        fi
    done

    # Check if the farming drive is already in use
    #for in_use_drive in "${in_use_drives[@]}"
    #do
    #    if [ "$in_use_drive" == "$drive" ]; then
    #        return 1
    #    fi
    #done
    # Check the disk usage on the remote destination
    local avail=$(ssh -T -c aes128-ctr -o Compression=no -x $user@$destination "df --output=avail $drive | tail -1 | tr -d '[:space:]'")
    if [ "$avail" -lt 90000000 ]; then
        echo "💰 $drive is full!"
        return 1
    fi

}

# Function to start a new transfer
function start_transfer() {
    local drive="$1"
    local file="$2"
    
    # Check if the drive is available for use
    if ! is_drive_available "$drive"; then
        return
    fi

    # Start the transfer using rsync in a detached screen session
    echo "🚜 Transferring $file to $drive"
    rsync -av --remove-source-files -e "ssh -T -c aes128-ctr -o Compression=no -x" $file $user@$destination:$drive &
    pids+=($!)
    moved_files+=("$file")
    last_drive="$drive"

    # Mark the drive as in use
    in_use_drives+=("$drive")
}


# Function to count the number of active transfers
function count_active_transfers() {
    local count=0
    for pid in "${pids[@]}"
    do
        if ps -p "$pid" > /dev/null
        then
            count=$((count + 1))
        fi
    done
    echo $count
}

# Loop indefinitely to keep transferring new .plot files
while true
do
    # Use find to get a list of .plot files that haven't been moved yet
    new_files=()
    while IFS= read -r -d $'\0' file; do
        if ! [[ "${moved_files[*]}" =~ $file ]]; then
            new_files+=("$file")
        fi
    done < <(find "$source_dir" -name "*.plot" -type f -print0)

    # Loop through the new plot files
    for file in "${new_files[@]}"
    do
        # Check if there are already $max_transfers active transfers
        if [ "$(count_active_transfers)" -ge $max_transfers ]; then
            echo "🌽 There are already $max_transfers active transfers. Waiting for a slot to become available..."
            sleep 10
            break
        fi

        # Shuffle the list of farming drives
        shuf_farming_drives=($(shuf -e "${farming_drives[@]}"))

        # Loop through the shuffled list to find an available drive
        drive=""
        for candidate_drive in "${shuf_farming_drives[@]}"
        do
            # Check if the farming drive is available for use
            if is_drive_available "$candidate_drive"; then
                drive="$candidate_drive"
                break
            fi
        done

        # If no available drive was found, wait for a few seconds before checking again
        if [ "$drive" == "" ]; then
            echo "🌾 All farming drives are currently in use. Waiting for a slot to become available..."
            sleep 5
            continue
        fi

        # Start a new transfer
        start_transfer "$drive" "$file"

        # Check the status of transfer processes and remove the drive from in_use_drives if the process has completed
        for i in "${!pids[@]}"
        do
            if ! ps -p "${pids[$i]}" > /dev/null
            then
                unset pids[$i]
                # Find the corresponding drive and remove it from in_use_drives
                for j in "${!in_use_drives[@]}"
                do
                    if [ "${in_use_drives[$j]}" == "${last_drive}" ]; then
                        unset in_use_drives[$j]
                        break
                    fi
                done
            fi
        done

        # Wait for a few seconds before checking again
        sleep 5
    done
done

