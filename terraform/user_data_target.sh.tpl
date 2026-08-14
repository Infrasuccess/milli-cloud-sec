#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y curl dnf-plugins-core firewalld openssh-server python3
dnf install -y https://s3.${aws_region}.amazonaws.com/amazon-ssm-${aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

systemctl enable --now sshd
systemctl enable --now amazon-ssm-agent
systemctl enable --now docker
usermod -aG docker ec2-user

docker rm -f dvwa || true
docker pull vulnerables/web-dvwa
docker run -d --restart unless-stopped --name dvwa -p 80:80 vulnerables/web-dvwa

for _ in $(seq 1 30); do
  if curl -fsS http://127.0.0.1/ >/dev/null; then
    exit 0
  fi
  sleep 10
done

docker ps -a
docker logs dvwa || true
systemctl status amazon-ssm-agent --no-pager || true
echo "DVWA did not become reachable on port 80"
exit 1
