# https://github.com/XTLS/Xray-core v25.3.6
# https://github.com/xjasonlyu/tun2socks v2.5.2

FROM alpine:latest
RUN set -ex;
RUN apk update && apk add --no-cache iproute2

WORKDIR /app

COPY ./xray /app
COPY ./tun2socks /app
COPY ./start.sh /app

RUN chmod +x /app/xray
RUN chmod +x /app/xray
RUN chmod +x /app/start.sh

ENTRYPOINT ["sh", "-c"]

CMD ["/bin/sh /app/start.sh; tail -f /dev/null"]