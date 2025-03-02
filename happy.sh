#!/bin/bash

id=$*

if [ -z "$id" ]
then
  echo "id can't be empty"
  exit 1
fi

# bbr
curl https://raw.githubusercontent.com/teddysun/across/master/bbr.sh | bash

# v2ray
apt-get update && apt-get install -y curl unzip

curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh
bash install-release.sh
bash install-dat-release.sh


rm /etc/systemd/system/v2ray.service /etc/systemd/system/v2ray.service.d/10-donot_touch_single_conf.conf

rm -f install-release.sh install-dat-release.sh 
rm -rf /var/log/v2ray/ /etc/systemd/system/v2ray.service.d /etc/systemd/system/v2ray.service
mv /usr/local/share/v2ray /usr/local/share/happy
mv /usr/local/etc/v2ray /usr/local/etc/happy
mv /usr/local/bin/v2ray /usr/local/bin/happy


cat > /usr/local/etc/happy/config.json<<EOF
{
  "log": {
     "loglevel": "none"
  },
  "inbounds": [
    {
      "port": 3389,
      "listen":"0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$id",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
           "path": "/fuck"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF


cat > /etc/systemd/system/happy.service <<EOF
[Unit]
Description=happy Service
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/happy run -config /usr/local/etc/happy/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF


# 启动服务
systemctl enable happy.service --now
systemctl status happy.service
