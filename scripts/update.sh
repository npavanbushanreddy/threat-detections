#!/bin/bash

REPO_DIR="/opt/threat-detections"

cd $REPO_DIR || exit 1

echo "Pulling latest changes..."
git pull origin main

echo "Validating Suricata..."
sudo suricata -T -c /etc/suricata/suricata.yaml

if [ $? -eq 0 ]; then
    echo "Reloading Suricata..."
    sudo systemctl reload suricata
    echo "Update successful"
else
    echo "Validation failed. Not reloading."
fi
