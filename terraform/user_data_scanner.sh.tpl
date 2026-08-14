#!/usr/bin/env bash
set -euo pipefail

dnf update -y
dnf install -y nmap git jq dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

cat >/home/ec2-user/target.txt <<EOT
http://${target_ip}
EOT
chown ec2-user:ec2-user /home/ec2-user/target.txt
