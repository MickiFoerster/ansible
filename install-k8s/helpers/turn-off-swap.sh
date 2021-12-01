#!/bin/bash

swapoff -a
cat /etc/fstab | grep -v swap > /tmp/fstab && mv /tmp/fstab /etc/fstab &&
    echo "Swap disabled successfully" && exit 0
echo "error: Could not disable SWAP"
exit 1
