#!/bin/bash
dnf update
dnf install git -y
dnf install docker -y
systemctl start docker
systemctl enable docker
usermode -aG docker ec2-user
curl -L https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user
TOKEN=${user-data-git-token}
USER=${user-data-git-user-name}
git clone https://$TOKEN@github.com/$USER/bookstore-api-app.git
cd bookstore-api-app
docker build -t bookstore:latest .
docker-compose up -d