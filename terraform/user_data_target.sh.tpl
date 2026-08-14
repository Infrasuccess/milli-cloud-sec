#!/usr/bin/env bash
set -euo pipefail

dnf update -y
dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

docker rm -f dvwa || true
docker run -d --name dvwa -p 80:80 vulnerables/web-dvwa
