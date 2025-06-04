#!/bin/bash

# Update and install dependencies
apt update -y
apt install -y nginx git nodejs npm
sudo npm install -g n
sudo n 18

# Clone your React app from GitHub
cd /home/ubuntu
git clone https://github.com/sallmayasser/3-tier-AWS-architecture-using-Terraform.git
cd 3-tier-AWS-architecture-using-Terraform/Frontend

# Install dependencies
npm install

# Build with dynamic backend URL from Terraform
REACT_APP_API_URL="http://${backend_alb_dns}" 
npm run build

# Copy build files to Nginx
cp -r build/* /var/www/html/

# Restart Nginx
systemctl restart nginx
