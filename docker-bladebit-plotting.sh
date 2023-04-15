# Fill in your CONTRACT and FARMERKEY to make plots with 512GB of Memory.

docker kill akash-chia ; docker rm akash-chia
docker run -d -p 80:8080 \
-e VERSION=1.6.0 \
-e CONTRACT= \
-e FARMERKEY= \
-e PLOTTER=bladebit \
-e BUCKETS=64 \
-e PLOT_SIZE=32 \
-e FINAL_LOCATION=local \
-e CPU_UNITS=32 \
-e MEMORY_UNITS=420Gi \
-e STORAGE_UNITS=1200Gi \
--privileged \
--expose 80/tcp \
--name akash-chia \
cryptoandcoffee/akash-chia:316
