#!/usr/bin/env bash
set -euo pipefail

yum update -y
yum install -y nmap git jq
amazon-linux-extras install docker -y || true
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

cat >/home/ec2-user/target.txt <<EOT
http://${target_ip}
EOT
chown ec2-user:ec2-user /home/ec2-user/target.txt
