#!/bin/bash

# Script to automatically generate Cloudflare tunnel config.yml based on subdomains.json

CONFIG_FILE="./config/config.yml"
SUBDOMAINS_FILE="./subdomains.json"
CREDENTIALS_FILE="/etc/cloudflared/c875878d-99ae-4550-9f1b-03bdac260c88.json"
TUNNEL_ID="c875878d-99ae-4550-9f1b-03bdac260c88"

# Generate the config.yml file
cat > $CONFIG_FILE << EOF
tunnel: $TUNNEL_ID
credentials-file: $CREDENTIALS_FILE

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

echo "Config file generated successfully!"

# Restart the cloudflared service to apply changes
echo "Restarting cloudflared service..."
sudo systemctl restart cloudflared 2>/dev/null || docker restart solodevmark 2>/dev/null || echo "Please restart your cloudflared service manually"

echo ""
echo "IMPORTANT: For the subdomains to work, you also need to create DNS records in Cloudflare."
echo "Run './create-dns-records.sh' to automatically create DNS records for all subdomains."
echo ""

# Save configuration to GitHub
echo "Saving configuration to GitHub..."
./save-to-github.sh

echo "Setup complete!"