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
    "loglevel": $(if [ -z $LOG_LEVEL ]; then
                   echo "\"warning\""
                else
                   echo "$LOG_LEVEL"
                fi)
  },
  "inbounds": [
    $(if [ ! -z $DOKODEMO_DOOR_PORT ]; then
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
    fi)
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
                $(if [ -z $XHTTP_PATH ]; then
                  echo "\"flow\": \"xtls-rprx-vision\""
                else
                  echo "\"flow\": \"\""
                fi)
              }
            ]
          }
        ]
      },
      "streamSettings": {
        $(if [ -z $XHTTP_PATH ]; then
            echo "\"network\": \"raw\","
        else
            echo "\"network\": \"xhttp\","
            echo "\"xhttpSettings\": { \"mode\": \"auto\", \"host\": \"\", \"path\":\"$XHTTP_PATH\" },"
        fi)
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
