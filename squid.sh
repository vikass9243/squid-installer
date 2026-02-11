#!/bin/bash

set -e

echo "====== Squid Proxy Auto Installer ======"

# Ask for username
read -p "Enter proxy username: " PROXY_USER

# Ask for password (hidden)
read -s -p "Enter proxy password: " PROXY_PASS
echo ""
read -s -p "Confirm proxy password: " PROXY_PASS2
echo ""

if [ "$PROXY_PASS" != "$PROXY_PASS2" ]; then
    echo "❌ Passwords do not match. Exiting."
    exit 1
fi

echo "🔄 Installing Squid..."
apt update -y
apt install -y squid apache2-utils ufw

# Create password file
htpasswd -bc /etc/squid/passwd "$PROXY_USER" "$PROXY_PASS"

# Write squid config
cat >/etc/squid/squid.conf <<EOF
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm SquidProxy
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
echo "Username: $PROXY_USER"
echo "--------------------------------------"
