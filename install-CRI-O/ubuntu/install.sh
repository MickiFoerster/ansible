#!/bin/bash
# Installation instructions taken from https://kubernetes.io/docs/setup/production-environment/container-runtimes/

if [ -z "$1" ]; then
    echo "error: First argument (version) is missing"
    exit 1;
fi
CRI_VERSION=$1

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

. /etc/os-release

OS=xUbuntu_${VERSION_ID}

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRI_VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRI_VERSION/$OS/ /
EOF

cd /tmp
url=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key
if ! curl -OL ${url} ; then
    echo "error: curl: could not download file from ${url}"
    exit 1
fi
if grep -qs "Error 404" Release.key; then
    echo "error: URL ${url} let to HTTP 404 error"
    exit 1
fi
cat Release.key | \
	sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

url=https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRI_VERSION/$OS/Release.key 
if ! curl -OL ${url} ; then
    echo "error: curl: could not download file from ${url}"
    exit 1
fi
if grep -qs "Error 404" Release.key; then
    echo "error: URL ${url} let to HTTP 404 error"
    exit 1
fi
cat Release.key | \
	sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg add -

sudo apt-get update
t=/tmp/cri-o.lst
apt search cri-o 2>/dev/null | grep "^cri-o[-\.0-9]*\/" | cut -d'/' -f1 >$t
if [[ $(cat $t | wc -l) > 1 ]]; then
    cat $t | grep ${CRI_VERSION} >${t}~
    mv ${t}~ $t
    if [[ $(cat $t | wc -l) != 1 ]]; then
        echo "error: multiple results for cri-o:"
        cat $t
        exit 1
    fi
fi

sudo apt-get install -y $(cat $t) cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio --now

set +e
set +x

