#!/bin/bash

echo "====== Squid Proxy Auto Installer ======"

apt update -y
apt install squid apache2-utils ufw -y

# Generate Random Username & Password
USER="user$(shuf -i 1000-9999 -n 1)"
PASS="$(openssl rand -base64 12)"

echo "🔐 Creating Proxy User..."

# Create password file
htpasswd -cb /etc/squid/passwd $USER $PASS

# Backup old config
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Write fresh squid config
cat > /etc/squid/squid.conf <<EOF
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Squid Proxy
acl auth_users proxy_auth REQUIRED

http_access allow auth_users
http_access deny all

via off
forwarded_for delete

request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access All allow all

cache deny all
access_log /var/log/squid/access.log
EOF

systemctl restart squid
systemctl enable squid
ufw allow 3128

SERVER_IP=$(curl -s ifconfig.me)

echo ""
echo "✅ Squid Installed Successfully!"
echo "--------------------------------------"
echo "Proxy: $SERVER_IP:3128"
echo "Username: $USER"
echo "Password: $PASS"
echo "--------------------------------------"
