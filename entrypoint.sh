#!/bin/sh

SERVER_IP_ADDRESS=$(ping -c 1 $SERVER_ADDRESS | awk -F'[()]' '{print $2}')

if [ -z "$SERVER_IP_ADDRESS" ]; then
  echo "Cannot resolve server IP"
  exit 1
fi

config_hs5t() {
cat > config_hs5t.yaml << EOF
misc:
  log-level: 'warn'
tunnel:
  name: tun0
  mtu: 9000
  ipv4: 172.17.0.1
  post-up-script: route.sh
socks5:
  address: 127.0.0.1
  port: 10808
  udp: udp
  mark: 438
EOF
}

config_xray() {
cat <<EOF > config_xray.json
{
  "log": {
    "loglevel": $([ -z $LOG_LEVEL ] && (echo "\"warning\"") || (echo "$LOG_LEVEL"))
  },
  "inbounds": [
    $(
        if [ ! -z $DOKODEMO_DOOR_PORT ]; then
            echo "{"
            echo "\"tag\": \"dokodemo-door\"",
            echo "\"port\": $DOKODEMO_DOOR_PORT",
            echo "\"protocol\": \"dokodemo-door\"",
            echo "\"settings\": {"
            echo "\"address\": \"$DOKODEMO_DOOR_ADDRESS\"",
            echo "\"port\": $DOKODEMO_DOOR_PORT",
            echo "\"network\": \"tcp,udp\""
            echo "}"
            echo "},"
        fi
    )
    {
      "tag": "socks",
      "port": 10808,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "settings": {
        "udp": true,
        "auth": "noauth",
        "allowTransparent": false
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "routeOnly": false
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "$SERVER_ADDRESS",
            "port": $SERVER_PORT,
            "users": [
              {
                "id": "$USER_ID",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "fingerprint": "random",
          "serverName": "$SNI",
          "publicKey": "$PBK",
          "shortId": "$SID"
        }
      }
    }
  ]
}
EOF
}

config_route() {
    echo "#!/bin/sh" > route.sh
    chmod +x route.sh
    echo "ip route add $SERVER_IP_ADDRESS/32 via 172.16.0.1" >> route.sh
    echo "ip route del default" >> route.sh
    echo "ip route add default via 172.17.0.1" >> route.sh
}

run() {
    cd /app
    config_hs5t
    config_xray
    config_route
    ./hev-socks5-tunnel config_hs5t.yaml &
    ./xray run -config config_xray.json
}

run || exit 1%
