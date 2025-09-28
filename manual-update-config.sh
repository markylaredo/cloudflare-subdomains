#!/bin/bash

# Manual update script for Cloudflare tunnel configuration
# This script manually updates the configuration based on subdomains.json

CONFIG_FILE="./config/config.yml"
SUBDOMAINS_FILE="./subdomains.json"
LOG_FILE="./manual-update.log"
CHECKSUM_FILE="./.subdomains_checksum"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to update configuration
update_config() {
    log_message "Updating configuration..."

    # Generate the config.yml file
    cat > $CONFIG_FILE << EOF
tunnel: c875878d-99ae-4550-9f1b-03bdac260c88
credentials-file: /etc/cloudflared/c875878d-99ae-4550-9f1b-03bdac260c88.json

ingress:
EOF

    # Read subdomains from JSON and add them to config
    python3 << EOF >> $CONFIG_FILE
import json
with open('$SUBDOMAINS_FILE') as f:
    data = json.load(f)
    for subdomain in data['subdomains']:
        print('  - hostname: {}.solodevmark.com'.format(subdomain['name']))
        print('    service: http://{}:{}'.format(subdomain['host'], subdomain['port']))
EOF

    # Add default 404 rule
    echo "  - service: http_status:404" >> $CONFIG_FILE

    log_message "Configuration updated successfully!"

    # Restart the cloudflared service to apply changes
    log_message "Restarting cloudflared service..."
    docker restart solodevmark 2>/dev/null || {
        log_message "Failed to restart docker container, trying systemctl..."
        sudo systemctl restart cloudflared 2>/dev/null || {
            log_message "Could not restart cloudflared service. Please restart manually."
        }
    }

    # Save configuration to GitHub
    log_message "Saving configuration to GitHub..."
    ./save-to-github.sh 2>/dev/null || log_message "Failed to save to GitHub"

    # Update the checksum file
    if command -v md5sum &> /dev/null; then
        md5sum "$SUBDOMAINS_FILE" > "$CHECKSUM_FILE"
    elif command -v sha256sum &> /dev/null; then
        sha256sum "$SUBDOMAINS_FILE" > "$CHECKSUM_FILE"
    fi

    log_message "Configuration update process completed!"
}

# Function to check if file has changed
has_file_changed() {
    if [ ! -f "$CHECKSUM_FILE" ]; then
        return 0  # File doesn't exist, consider it changed
    fi

    if command -v md5sum &> /dev/null; then
        if [ "$(md5sum "$SUBDOMAINS_FILE" | cut -d' ' -f1)" != "$(cat "$CHECKSUM_FILE" | cut -d' ' -f1)" ]; then
            return 0  # File has changed
        fi
    elif command -v sha256sum &> /dev/null; then
        if [ "$(sha256sum "$SUBDOMAINS_FILE" | cut -d' ' -f1)" != "$(cat "$CHECKSUM_FILE" | cut -d' ' -f1)" ]; then
            return 0  # File has changed
        fi
    else
        # Fallback: just run update
        return 0
    fi

    return 1  # File has not changed
}

# Check if required files exist
if [ ! -f "$SUBDOMAINS_FILE" ]; then
    echo "Error: $SUBDOMAINS_FILE does not exist."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE does not exist."
    exit 1
fi

# Check if file has changed before updating
if has_file_changed; then
    update_config
    echo "Configuration updated."
else
    log_message "No changes detected in subdomains.json, skipping update."
    echo "No changes detected in subdomains.json, skipping update."
fi