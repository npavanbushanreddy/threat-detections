#!/bin/bash

set -e

REPO_DIR="/opt/threat-detections"

cd $REPO_DIR || exit 1

echo "=== Starting Deployment ==="

echo "🔄 Pulling latest changes..."
git pull origin main

echo "🔍 Validating Suricata..."
if ! sudo suricata -T -c /etc/suricata/suricata.yaml; then
    echo "❌ Suricata validation failed. Aborting deployment."
    exit 1
fi
echo "✔ Suricata validation successful."

echo "♻ Reloading Suricata..."
sudo systemctl reload suricata

echo "♻ Restarting Wazuh Manager..."
sudo systemctl restart wazuh-manager

sleep 3

echo "🔍 Checking Wazuh status..."
if ! sudo systemctl is-active --quiet wazuh-manager; then
    echo "❌ Wazuh failed to start. Aborting deployment."
    exit 1
fi
echo "✔ Wazuh is running."

echo "✅ Deployment successful."
