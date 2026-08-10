#!/usr/bin/env bash
set -euo pipefail

yum update -y
amazon-linux-extras install docker -y || true
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

docker rm -f dvwa || true
docker run -d --name dvwa -p 80:80 vulnerables/web-dvwa
