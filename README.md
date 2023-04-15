# chia-farming

Useful scripts to prepare drives and move plots.

# Prepare drives for Chia Farming
# Create C7 Bladebit GPU Plots
# Farm Bladebit GPU Plots
# Move plots efficiently
# Create BLadebit plots with 512GB System and Access them in File Explorer

| Emoji | Task                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|-------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🪓    | Prepare drives for Chia Farming                                                                   | Before you start farming Chia, you'll need to prepare your hard drives. This involves partitioning, formatting, and creating plots on them. To do this efficiently, you can use scripts such as `prepare-drives.sh` to automate the process. These scripts allow you to set the number of plots to create, the size of the plots, and other parameters to optimize the plotting process. The `prepare-drives.sh` script is very powerful and potentially dangerous, so it's important to understand what it does and use it carefully. The script formats the specified drives with an ext4 file system, sets reserve space to 0%, disables write-cache, and optimizes read-ahead caching for performance. The script also powers off the drive to finalize the `hdparm` commands. Make sure to only run this script on drives that are dedicated to Chia farming and not used for any other purposes.|
| 🌱    | Create Bladebit Plots                                                                            | The Bladebit algorithm is a plotting algorithm for Chia that is faster than the CPU-based plotting algorithms and doesn't require CUDA. To create Bladebit plots, you can use the `bladebit-plotting.sh` script. The script runs a Docker container that is configured with the necessary environment variables to create Bladebit plots efficiently. You'll need to fill in your CONTRACT and FARMERKEY to generate plots. Once you have filled in the required information, you can run the script to create plots with 512GB of memory. The container exposes port 80, which allows you to access the file explorer at port 80. This can be useful for managing and organizing your plots. With Bladebit plots, you can potentially earn more rewards and speed up your Chia farming operation.
| 🪚    | Create C7 Bladebit GPU Plots                                                                      | If you have a compatible GPU and want to create C7 Bladebit plots, you can use the `bladebit-cuda-plotting.sh` script. This script uses the `bladebit_cuda` command-line tool to create plots with your GPU. The tool requires NVIDIA driver version 530 or greater. You'll need to provide your FARMER_KEY and CONTRACT_ADDRESS to generate plots. Once you have filled in the required information, you can run the script to create plots with your GPU. The script generates plots with a plot count of 50000 and a thread count of 16. The plots are stored in the specified final directory. With C7 plots, you can further accelerate your Chia farming and potentially earn more rewards. |
| 🌾    | Farm Bladebit GPU Plots                                                                           | Once you've created your Bladebit CUDA plots, you'll need to farm them to earn rewards. To do this, you can use a full node of the Chia blockchain and point it to your plots, or you can use a Docker container to farm your plots. The `harvester-compose.yml` file provides a convenient way to configure a Docker container to farm your Bladebit CUDA plots. The file specifies a service named `chia_harvester` that runs a Docker container based on the `cryptoandcoffee/chia-node-cuda:1` image. The container is configured to run as a harvester, and it connects to your farmer using the specified `farmer_address` and `farmer_port`. The container also specifies the location of the CA folder from your farmer, which is mounted as a volume inside the container. This allows the container to access your Bladebit CUDA plots, which are stored in the `/plots` directory. Once you've configured the `harvester-compose.yml` file, you can start the Docker container to farm your Bladebit CUDA plots and wait for the rewards to roll in. Note that farming Chia requires a lot of disk space, so make sure you have enough hard drive space to accommodate your plots. |
| 🚛    | Move plots efficiently                                                                            | If you need to move your plots to another computer or a different hard drive, you'll want to do so efficiently to avoid long transfer times. The `plot-mover.sh` script provides a way to automate the process of transferring your plots to your farming drives. The script uses a list of farming drives and shuffles it to find an available drive. If a drive is available, the script checks for new plot files in the specified source directory and moves the first available plot file to the farming drive. The script can handle multiple transfers simultaneously and waits for a few seconds before checking for new plot files or available drives again. The script can help you manage your Chia farming operation and keep your plots organized. Note that you'll need to configure the script with the location of your source directory and the list of your farming drives. Make sure that your farming drives are mounted and have enough free disk space to accommodate your plots. Also, be aware that the script is configured to use a maximum of three transfer processes at a time, which you can adjust according to your preferences. |
