#!/bin/bash

XRAY_LINK="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"
TUN2SOCKS_LINK="https://github.com/xjasonlyu/tun2socks/releases/latest/download/tun2socks-linux-arm64.zip"

sudo apt -y install unzip
rm xray
rm tun2socks
mkdir tmp
curl -L -o tmp/xray.zip $XRAY_LINK
curl -L -o tmp/tun2socks.zip $TUN2SOCKS_LINK
cd tmp
unzip xray.zip
unzip tun2socks.zip
cp xray ../xray
cp tun2socks-linux-arm64 ../tun2socks
cd ..
rm -rf tmp/

docker buildx build -f Dockerfile --no-cache --progress=plain --platform linux/arm64 --output=type=docker --tag savimisha/mikrotik-xray:latest .
#docker push savimisha/mikrotik-xray:latest