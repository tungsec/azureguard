#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

echo -e "    ___                        ______                     __"
echo -e "   /   |____  __  __________  / ____/_  ______ __________/ /"
echo -e "  / /| /_  / / / / / ___/ _ \/ / __/ / / / __  / ___/ __  / "
echo -e " / ___ |/ /_/ /_/ / /  /  __/ /_/ / /_/ / /_/ / /  / /_/ /  "
echo -e "/_/  |_/___/\__,_/_/   \___/\____/\__,_/\__,_/_/   \__,_/   "
echo -e "                                                            "

rm -rf /opt/azureguard 2>/dev/null || true

GIT_BRANCH=main

# Clone to /opt
echo "Cloning $GIT_BRANCH branch from azureguard repo"
git clone https://github.com/9aRpu/azureguard -b $GIT_BRANCH /opt/azureguard
cd /opt/azureguard

# Check updates
echo "Checking updates"
source ./scripts/subinstallers/check_updates.sh

# SSH keys
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH keypair for $USER"
    ssh-keygen -t rsa -b 4096 -N "" -m pem -f ~/.ssh/id_rsa -q
    
    # Authorized keys
    echo "from=\"172.16.0.0/12,192.168.0.0/16,10.0.0.0/8\" $(cat ~/.ssh/id_rsa.pub)" > ~/.ssh/authorized_keys
else
    echo "SSH key exists for $USER"
fi
