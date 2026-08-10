#!/usr/bin/env bash
set -euo pipefail

sudo yum update -y
sudo amazon-linux-extras install docker -y || true
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
