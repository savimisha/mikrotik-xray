FROM alpine:latest

RUN set ex;

WORKDIR /app

COPY ./xray /app
COPY ./hev-socks5-tunnel /app
COPY ./entrypoint.sh /app

RUN chmod +x /app/xray
RUN chmod +x /app/hev-socks5-tunnel
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]