#!/bin/bash

# Auto-update Cloudflare tunnel configuration when subdomains.json changes
# This script monitors the subdomains.json file and automatically updates
# the tunnel configuration when changes are detected.

CONFIG_FILE="./config/config.yml"
SUBDOMAINS_FILE="./subdomains.json"
LOG_FILE="./auto-update.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to update configuration
update_config() {
    log_message "Detected changes in subdomains.json, updating configuration..."

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

    log_message "Configuration update process completed!"
}

# Check if inotifywait is available
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed. Please install inotify-tools package."
    echo "On Ubuntu/Debian: sudo apt-get install inotify-tools"
    echo "On CentOS/RHEL: sudo yum install inotify-tools"
    exit 1
fi

# Check if required files exist
if [ ! -f "$SUBDOMAINS_FILE" ]; then
    echo "Error: $SUBDOMAINS_FILE does not exist."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE does not exist."
    exit 1
fi

log_message "Starting auto-update monitor for $SUBDOMAIN_FILE..."

# Monitor the directory for changes to subdomains.json
inotifywait -m -e modify,create,delete "$(dirname "$SUBDOMAINS_FILE")" --format '%f' | while read file; do
    if [ "$file" = "$(basename "$SUBDOMAINS_FILE")" ]; then
        log_message "Change detected in $SUBDOMAINS_FILE"
        update_config
    fi
done