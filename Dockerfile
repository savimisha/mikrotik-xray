FROM alpine:latest AS build
ARG TARGETPLATFORM
ARG XRAY_ARM="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm32-v7a.zip"
ARG XRAY_ARM64="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"

RUN set ex;

RUN apk add --no-cache curl unzip

RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then \
    curl -L -o /xray.zip $XRAY_ARM64; else \
    curl -L -o /xray.zip $XRAY_ARM; fi

RUN unzip /xray.zip

FROM alpine:latest

WORKDIR /app

COPY --from=build /xray /app/xray

COPY ./entrypoint.sh /app

RUN chmod +x /app/xray
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
