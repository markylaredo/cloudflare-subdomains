#!/bin/bash

# Script to delete all DNS records in Cloudflare

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

# Function to delete a DNS record in Cloudflare
delete_dns_record() {
    local subdomain=$1
    local domain="solodevmark.com"
    local full_domain="${subdomain}.${domain}"
    
    # First, get the DNS record ID
    response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?type=CNAME&name=$full_domain" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")
    
    # Check if records were found
    success=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('success', False))")
    
    if [ "$success" = "True" ]; then
        # Get the record ID
        record_count=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data['result']))")
        
        if [ "$record_count" -gt 0 ]; then
            record_id=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['result'][0]['id'])")
            
            # Delete the DNS record
            delete_response=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$record_id" \
                -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
                -H "Content-Type: application/json")
            
            delete_success=$(echo "$delete_response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('success', False))")
            
            if [ "$delete_success" = "True" ]; then
                echo "DNS record for $full_domain deleted successfully!"
                return 0
            else
                echo "Failed to delete DNS record for $full_domain"
                echo "Response: $delete_response"
                return 1
            fi
        else
            echo "No DNS record found for $full_domain"
            return 0
        fi
    else
        echo "Failed to fetch DNS records for $full_domain"
        echo "Response: $response"
        return 1
    fi
}

echo "Deleting DNS records for all subdomains..."

# Read subdomains from JSON and delete DNS records for each
python3 -c "
import json
import sys

# Read subdomains from JSON
try:
    with open('subdomains.json', 'r') as f:
        data = json.load(f)
    
    for sd in data['subdomains']:
        print(sd['name'])
except FileNotFoundError:
    print('No subdomains.json file found')
    exit(0)
except Exception as e:
    print(f'Error reading subdomains: {e}', file=sys.stderr)
    exit(1)
" | while IFS= read -r subdomain; do
    if [ -n "$subdomain" ]; then
        delete_dns_record "$subdomain"
    fi
done

echo "DNS record deletion process completed!"