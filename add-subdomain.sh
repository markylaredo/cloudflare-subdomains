#!/bin/bash

# Script to add a new subdomain to Cloudflare tunnel configuration

if [ $# -ne 3 ]; then
    echo "Usage: $0 <subdomain> <host> <port>"
    echo "Example: $0 infatrack 192.168.10.153 3001"
    exit 1
fi

SUBDOMAIN=$1
HOST=$2
PORT=$3

# Update the subdomains.json file
python3 -c "
import json
import sys

subdomain = '$SUBDOMAIN'
host = '$HOST'
port = int('$PORT')

# Read existing subdomains
try:
    with open('subdomains.json', 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    data = {'subdomains': []}

# Check if subdomain already exists
found = False
for sd in data['subdomains']:
    if sd['name'] == subdomain:
        sd['host'] = host
        sd['port'] = port
        found = True
        break

# Add new subdomain if it doesn't exist
if not found:
    data['subdomains'].append({
        'name': subdomain,
        'host': host,
        'port': port
    })

# Write updated data back to file
with open('subdomains.json', 'w') as f:
    json.dump(data, f, indent=2)

print(f'Subdomain {subdomain} added/updated successfully!')
"

# Regenerate the config file and restart the service
./generate-config.sh

# Create DNS record in Cloudflare
echo "Creating DNS record for $SUBDOMAIN.solodevmark.com..."
./create-dns-records.sh "$SUBDOMAIN"

# Save configuration to GitHub
echo "Saving configuration to GitHub..."
./save-to-github.sh