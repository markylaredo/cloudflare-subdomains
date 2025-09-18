#!/bin/bash

# Script to automatically create DNS records in Cloudflare

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Check if required environment variables are set
if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo "Error: Missing Cloudflare API credentials."
    echo "Please add the following to your .env file:"
    echo "CLOUDFLARE_API_TOKEN=your_api_token_here"
    echo "CLOUDFLARE_ZONE_ID=your_zone_id_here"
    exit 1
fi

# Get tunnel ID from config file
TUNNEL_ID=$(grep "^tunnel:" config/config.yml | awk '{print $2}')

if [ -z "$TUNNEL_ID" ]; then
    echo "Error: Could not find tunnel ID in config file"
    exit 1
fi

# Function to create a DNS record in Cloudflare
create_dns_record() {
    local subdomain=$1
    local domain="solodevmark.com"
    local full_domain="${subdomain}.${domain}"
    local cname_content="${TUNNEL_ID}.cfargotunnel.com"
    
    echo "Creating DNS record for $full_domain..."
    echo "CNAME content: $cname_content"
    
    # Create DNS record using Cloudflare API
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data '{
            "type": "CNAME",
            "name": "'"$subdomain"'",
            "content": "'"$cname_content"'",
            "ttl": 1,
            "proxied": true
        }')
    
    # Check if the request was successful
    success=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('success', False))")
    
    if [ "$success" = "True" ]; then
        echo "DNS record for $full_domain created successfully!"
        return 0
    else
        # Check if the error is because the record already exists
        errors=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('errors', []))")
        if echo "$errors" | grep -q "already exists"; then
            echo "DNS record for $full_domain already exists. Skipping..."
            return 0
        else
            echo "Failed to create DNS record for $full_domain"
            echo "Response: $response"
            return 1
        fi
    fi
}

# If script is called with arguments, create a single DNS record
if [ $# -eq 1 ]; then
    create_dns_record "$1"
    exit $?
fi

# If no arguments, create DNS records for all subdomains in subdomains.json
echo "Creating DNS records for all subdomains..."

# Read subdomains from JSON and create DNS records for each
python3 -c "
import json
import sys

# Read subdomains from JSON
try:
    with open('subdomains.json', 'r') as f:
        data = json.load(f)
    
    for sd in data['subdomains']:
        print(sd['name'])
except Exception as e:
    print(f'Error reading subdomains: {e}', file=sys.stderr)
    exit(1)
" | while IFS= read -r subdomain; do
    if [ -n "$subdomain" ]; then
        create_dns_record "$subdomain"
    fi
done

echo "DNS record creation process completed!"