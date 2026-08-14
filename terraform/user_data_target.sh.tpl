#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y dnf-plugins-core firewalld
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

systemctl enable --now docker
usermod -aG docker ec2-user

docker rm -f dvwa || true
docker run -d --restart unless-stopped --name dvwa -p 80:80 vulnerables/web-dvwa
