#!/bin/bash

# Update and install dependencies
apt update -y
apt install -y nginx git nodejs npm
sudo npm install -g n
sudo n 18

# Configure nginx with proxy for /api to backend ALB
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://$backend_alb_dns:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF


# Restart nginx to apply config
systemctl reload nginx

# Clone your React app from GitHub
cd /home/ubuntu
git clone https://github.com/sallmayasser/3-tier-AWS-architecture-using-Terraform.git
cd 3-tier-AWS-architecture-using-Terraform/Frontend

# Install dependencies
npm install

# Build with relative API URL for proxying via Nginx
REACT_APP_API_URL="/api" npm run build

# Copy build files to Nginx
cp -r build/* /var/www/html/

# Restart Nginx after copying files
systemctl restart nginx
