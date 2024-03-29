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
apt-get update && apt-get install -y curl unzip nginx

curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh
bash install-release.sh
bash install-dat-release.sh


cat > /usr/local/etc/v2ray/config.json<<EOF
{
  "inbounds": [
    {
      "port": 10000,
      "listen":"0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$id",
            "level": 0,
            "email": "love@v2fly.org"
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

mkdir /etc/nginx/ssl

cat > /etc/nginx/sites-enabled/free.conf<<EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen       443 ssl http2;

    location / {
        return 404;
    }

    location /fuck {
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }
    ssl_certificate ssl/free.pem;
    ssl_certificate_key ssl/free.key;
}
EOF

# 启动服务
systemctl enable v2ray.service --now
systemctl status v2ray.service
