#!/bin/bash

# Installation instructions taken from https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


set -e
set -x

OS=xUbuntu_20.04
VERSION=1.22:

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${OS}/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${VERSION}/${OS}/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${OS}/Release.key | sudo tee /etc/apt/trusted.gpg.d/libcontainers.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.22:/1.22.0/${OS}/Release.key | sudo tee /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg


sudo apt-get update
sudo apt-get install cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio --now

set +e
set +x


