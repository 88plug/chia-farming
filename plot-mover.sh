#!/bin/bash

# Set the source directory where your plots are located
source_dir="/home/user/fast-cache/final"

# Set the list of farming drives you want to use
farming_drives=(
    "/home/user/chia-drives/chia-sabrent-x1"
    "/home/user/chia-drives/chia-sabrent-x2"
    "/home/user/chia-drives/chia-sabrent-x3"
    "/home/user/chia-drives/chia-sabrent-x3"
    "/home/user/chia-drives/chia-sabrent-x4"
    "/home/user/chia-drives/chia-sabrent-x5"
    "/home/user/chia-drives/chia-sabrent-x6"
    "/home/user/chia-drives/chia-sabrent-x7"
    "/home/user/chia-drives/chia-sabrent-x8"
    "/home/user/chia-drives/chia-sabrent-x9"
    "/home/user/chia-drives/chia-sabrent-x10"
)

# Initialize a variable to store the last farming drive used
last_drive=""

# Initialize an array to store the PIDs of transfer processes
pids=()

# Initialize an array to store the names of plot files that have already been moved
moved_files=()

# Function to check if a farming drive is available for use
function is_drive_available() {
    local drive="$1"
    # Check if the farming drive is already being used for a transfer
    for pid in "${pids[@]}"
    do
        if lsof -w -p "$pid" | grep "$drive" > /dev/null
        then
            return 1
        fi
    done

    # Check if the farming drive has space available
    if ! df -h "$drive" | awk '{print $5}' | tail -1 | grep -q "^100"; then
        return 0
    fi

    # If the drive is full, remove it from the list
    farming_drives=("${farming_drives[@]/$drive}")
    echo "Drive $drive is full. Removing it from the list of available drives."
    return 1
}

# Function to move a plot file to a farming drive
function move_plot() {
    local drive="$1"
    local file="$2"
    # Move the plot file to the farming drive
    echo "Moving $file to $drive"
    mv "$file" "$drive/" &
    pids+=($!)
    moved_files+=("$file")
    last_drive="$drive"
}

# Loop indefinitely to keep transferring new .plot files
while true
do
    # Shuffle the list of farming drives
    shuf_farming_drives=($(shuf -e "${farming_drives[@]}"))

    # Loop through the shuffled list to find an available drive
    drive=""
    for candidate_drive in "${shuf_farming_drives[@]}"
    do
        # Check if the farming drive is mounted
        if [ -d "$candidate_drive" ]; then
            # Check if the farming drive is available for use
            if is_drive_available "$candidate_drive"; then
                drive="$candidate_drive"
                break
            fi
        else
            echo "Farming drive $candidate_drive is not mounted"
        fi
    done

    # If no available drive was found, wait for a few seconds before checking again
    if [ "$drive" == "" ]; then
    echo "All farming drives are currently in use. Waiting for a slot to become available..."
    sleep 5
    continue
fi

# Count the number of transfer processes running
transfer_count=${#pids[@]}

# If there are fewer than four transfer processes running, start a new transfer
if [ "$transfer_count" -lt 4 ]; then
    # Use find to get a list of .plot files that haven't been moved yet
    new_files=()
    while IFS= read -r -d $'\0' file; do
        if ! [[ "${moved_files[*]}" =~ $file ]]; then
            new_files+=("$file")
        fi
    done < <(find "$source_dir" -name "*.plot" -type f -print0)

    # If there are any new .plot files, move the first one to the farming drive
    if [ ${#new_files[@]} -gt 0 ]; then
        move_plot "$drive" "${new_files[0]}"
    fi
fi

# Check the status of transfer processes
for i in "${!pids[@]}"
do
    if ! ps -p "${pids[$i]}" > /dev/null
    then
        unset pids[$i]
    fi
done

# Wait for a few seconds before checking again
sleep 5
       
