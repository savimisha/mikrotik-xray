#!/bin/bash

XRAY_LINK="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"
TUN2SOCKS_LINK="https://github.com/xjasonlyu/tun2socks/releases/latest/download/tun2socks-linux-arm64.zip"
HEVSOCKS5TUNNEL_LINK="https://github.com/heiher/hev-socks5-tunnel/releases/latest/download/hev-socks5-tunnel-linux-arm64"

sudo apt -y install unzip curl
rm xray
#rm tun2socks
rm hev-socks5-tunnel
mkdir tmp
curl -L -o tmp/xray.zip $XRAY_LINK
#curl -L -o tmp/tun2socks.zip $TUN2SOCKS_LINK
curl -L -o hev-socks5-tunnel $HEVSOCKS5TUNNEL_LINK
cd tmp
unzip xray.zip
#unzip tun2socks.zip
cp xray ../xray
#cp tun2socks-linux-arm64 ../tun2socks
cd ..
rm -rf tmp/

docker buildx build -f Dockerfile --no-cache --progress=plain --platform linux/arm64 --output=type=docker --tag savimisha/mikrotik-xray:dev .
docker push savimisha/mikrotik-xray:dev