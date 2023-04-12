docker kill akash-chia ; docker rm akash-chia
docker run -d -p 80:8080 \
-e VERSION=1.6.0 \
-e CONTRACT=xch16txqvdlh67m9stvwmx848xzpgesd60swqxll3rrnnafunuluflds03jkt4 \
-e FARMERKEY=847b826e653279b9e54ce66a1c55cbfdb1ddc4118e70038cdfbaa7e5cb0a785087bc3a6f055f01bbbf84a2c6a3be4a97 \
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
