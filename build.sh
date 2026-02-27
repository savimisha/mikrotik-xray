#!/bin/bash

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx build -f Dockerfile --no-cache --progress=plain --platform linux/arm64,linux/arm/v7 --output=type=docker --tag savimisha/mikrotik-xray:hev .
docker push savimisha/mikrotik-xray:hev
