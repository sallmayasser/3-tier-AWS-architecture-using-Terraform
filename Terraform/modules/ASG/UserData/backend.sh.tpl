#!/bin/bash
apt update -y
apt install -y curl git awscli

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
curl -o /home/ubuntu/rds-combined-ca-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
apt install -y nodejs

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

MONGO_URI=$(aws ssm get-parameter --name "${ssm_param_name}" --with-decryption --query "Parameter.Value" --output text)

cd /home/ubuntu
git clone https://github.com/sallmayasser/3-tier-AWS-architecture-using-Terraform.git

cd 3-tier-AWS-architecture-using-Terraform/Backend
npm install
echo "MONGO_URI=$MONGO_URI" >.env
chown ubuntu:ubuntu .env

nohup npm start >>/home/ubuntu/app.log 2>&1 &
