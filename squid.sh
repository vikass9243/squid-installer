#!/bin/bash

echo "====== Squid Proxy Auto Installer ======"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Install Squid
echo "🔄 Installing Squid..."
apt update -y
apt install squid apache2-utils ufw -y

# Backup default config
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Basic Squid Config
cat > /etc/squid/squid.conf <<EOF
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all

cache deny all
access_log none
EOF

# Create password file
touch /etc/squid/passwd
chmod 640 /etc/squid/passwd
chown proxy:proxy /etc/squid/passwd

# Create user add command
cat > /usr/local/bin/squid-add-user <<'EOL'
#!/bin/bash
read -p "Enter Proxy Username: " USERNAME
htpasswd /etc/squid/passwd $USERNAME
systemctl restart squid
echo "User added successfully!"
EOL

chmod +x /usr/local/bin/squid-add-user

# Enable & restart squid
systemctl enable squid
systemctl restart squid

# Open firewall
ufw allow 3128/tcp
ufw reload

# Get Server IP
SERVER_IP=$(curl -s ifconfig.me)

echo ""
echo "======================================"
echo -e "${GREEN}✅ SQUID PROXY INSTALLED SUCCESSFULLY${NC}"
echo "======================================"
echo ""
echo "Proxy Address : $SERVER_IP:3128"
echo ""
echo -e "${GREEN}👉 NEXT STEP:${NC}"
echo -e "${GREEN}Run this command to create proxy user:${NC}"
echo ""
echo -e "${GREEN}    squid-add-user${NC}"
echo ""
echo "======================================"
