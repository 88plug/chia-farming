#Configures a Debian LXC Container to be a Farmer
apt-get install -y sudo aria2 gunzip
wget https://download.chia.net/dev/chia-blockchain-cli_1.7.1rc2-dev26-6a966913-1_amd64.deb
dpkg -i chia-blockchain-cli_1.7.1rc2-dev26-6a966913-1_amd64.deb
chia init
cd /root/.chia/mainnet/db/
aria2c https://torrents.chia.net/databases/mainnet/blockchain_v2_mainnet.2023-03-04.sqlite.gz.torrent
gunzip *.gz ; mv /root/.chia/mainnet/db/blockchain_v2_mainnet.2023-03-04.sqlite.gz /root/.chia/mainnet/db/blockchain_v2_mainnet.sqlite.gz
