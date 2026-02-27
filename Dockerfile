FROM alpine:latest AS build

ARG TARGETPLATFORM

ARG XRAY_ARM="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm32-v7a.zip"
ARG XRAY_ARM64="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"
ARG HEV_SOCKS5_ARM="https://github.com/heiher/hev-socks5-tunnel/releases/latest/download/hev-socks5-tunnel-linux-arm32v7"
ARG HEV_SOCKS5_ARM64="https://github.com/heiher/hev-socks5-tunnel/releases/latest/download/hev-socks5-tunnel-linux-arm64"

RUN set ex;

RUN apk add --no-cache curl unzip

RUN if [[ "$TARGETPLATFORM" == "linux/arm/v7" ]]; then \
    curl -L -o /xray.zip $XRAY_ARM && curl -L -o /hev-socks5-tunnel $HEV_SOCKS5_ARM; fi

RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then \
    curl -L -o /xray.zip $XRAY_ARM64 && curl -L -o /hev-socks5-tunnel $HEV_SOCKS5_ARM64; fi

RUN unzip /xray.zip

FROM alpine:latest

WORKDIR /app

COPY --from=build /xray /app/xray
COPY --from=build /hev-socks5-tunnel /app/hev-socks5-tunnel

COPY ./entrypoint.sh /app

RUN chmod +x /app/xray
RUN chmod +x /app/hev-socks5-tunnel
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
