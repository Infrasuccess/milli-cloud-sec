#!/usr/bin/env bash
set -euo pipefail

# Install docker first
bash /tmp/install_docker.sh

# Pull and run DVWA as vulnerable target for DAST learning
sudo docker rm -f dvwa || true
sudo docker run -d --name dvwa -p 80:80 vulnerables/web-dvwa
