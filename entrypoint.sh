#!/bin/sh

SERVER_IP_ADDRESS=$(ping -c 1 $SERVER_ADDRESS | awk -F'[()]' '{print $2}')

if [ -z "$SERVER_IP_ADDRESS" ]; then
  echo "Cannot resolve server IP"
  exit 1
fi

config_xray() {
cat <<EOF > config_xray.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "dokodemo-door",
      "port": $DOKODEMO_DOOR_PORT,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "$DOKODEMO_DOOR_ADDRESS",
        "port": $DOKODEMO_DOOR_PORT,
        "network": "tcp,udp"
      }
    },
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
    },
    {
      "tag": "tun",
      "port": 0,
      "protocol": "tun",
      "settings": {
        "name": "xray0",
        "MTU": 1500
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
        },
        "sockopt": {
          $([ "$FRAGMENT_ENABLE" = "true" ] && ( echo "\"dialerProxy\": \"fragment-proxy\"") || ( echo ""))
        }
      }
    },
    {
      "tag": "fragment-proxy",
      "protocol": "freedom",
      "settings": {
        "noises": [
          {
            "type": "$NOISES_TYPE",
            "delay": "$NOISES_DELAY",
            "packet": "$NOISES_PACKET"
          }
        ],
        "fragment": {
          "length": "$FRAGMENT_LENGTH",
          "packets": "tlshello",
          "interval": "$FRAGMENT_INTERVAL"
        }
      }
    }
  ]
}
EOF
}

run() {
    cd /app

    config_xray

    ip route add $SERVER_IP_ADDRESS/32 via 172.16.0.1

    ./xray run -config config_xray.json &

    while true; do
        if [ "$(ifconfig | grep xray0)" != "" ]; then
            break
        fi
        echo "Awaiting xray0 tun interface..."
        sleep 1
    done

    ip addr add 172.17.0.1/24 dev xray0
    ip route del default
    ip route add default via 172.17.0.1

    tail -f /dev/null
}

run || exit 1%
