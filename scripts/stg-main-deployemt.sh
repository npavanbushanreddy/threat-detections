#!/bin/bash

set -e

echo "=== Staging → Main Promotion Script ==="

# Fetch latest branches
echo "🔄 Fetching latest changes..."
git fetch origin

# Switch to staging automatically
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "staging" ]; then
    echo "🔀 Switching to staging branch..."
    git checkout staging
fi

# Pull latest staging
echo "⬇ Pulling latest staging..."
git pull origin staging

echo "🔍 Validating Suricata configuration..."
if ! sudo suricata -T -c /etc/suricata/suricata.yaml; then
    echo "❌ Validation failed. Aborting promotion."
    exit 1
fi

echo "✔ Validation successful."

# Switch to main
echo "🔀 Switching to main branch..."
git checkout main

# Pull latest main
git pull origin main

echo "🔀 Merging staging into main..."
git merge staging

echo "🚀 Pushing main to origin..."
git push origin main

echo "✅ Promotion complete. Webhook will deploy automatically."
