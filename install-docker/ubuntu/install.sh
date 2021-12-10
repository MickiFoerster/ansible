#!/bin/bash
# Installation instructions taken from 
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

sudo apt-get update 

# Uninstall possible existing installations
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

f=/tmp/docker-key.gpg
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg >$f; then
    echo "error: could not download docker gpg key"
    exit 1
fi
cat $f | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

if ! sudo docker run hello-world | grep -qs "Hello from Docker"; then 
    echo "error: could not start Hello World container"; 
    exit 1;
fi

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
