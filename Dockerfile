FROM alpine:latest
RUN set -ex;
RUN apk update && apk add --no-cache iproute2

WORKDIR /app

COPY ./xray /app
#COPY ./tun2socks /app
COPY ./hev-socks5-tunnel /app
COPY ./hev-socks5-tunnel.yaml /app
COPY ./start.sh /app

RUN chmod +x /app/xray
#RUN chmod +x /app/tun2socks
RUN chmod +x /app/hev-socks5-tunnel
RUN chmod +x /app/start.sh

ENTRYPOINT ["sh", "-c"]

CMD ["/bin/sh /app/start.sh; tail -f /dev/null"]