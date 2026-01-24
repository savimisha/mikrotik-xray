#!/bin/bash

XRAY_LINK="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"

sudo apt -y install unzip curl
rm xray
mkdir tmp
curl -L -o tmp/xray.zip $XRAY_LINK
cd tmp
unzip xray.zip
cp xray ../xray
cd ..
rm -rf tmp/

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx build -f Dockerfile --no-cache --progress=plain --platform linux/arm64 --output=type=docker --tag savimisha/mikrotik-xray .
docker push savimisha/mikrotik-xray
