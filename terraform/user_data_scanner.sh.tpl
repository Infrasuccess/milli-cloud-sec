#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y nmap git jq dnf-plugins-core firewalld openssh-server python3
dnf install -y https://s3.${aws_region}.amazonaws.com/amazon-ssm-${aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

systemctl enable --now sshd
systemctl enable --now amazon-ssm-agent
systemctl enable --now docker
usermod -aG docker ec2-user

cat >/home/ec2-user/target.txt <<EOT
http://${target_ip}
EOT
chown ec2-user:ec2-user /home/ec2-user/target.txt
