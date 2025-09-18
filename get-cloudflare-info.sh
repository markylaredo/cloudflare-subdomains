#!/bin/bash

# Script to get Cloudflare account information and zone ID

echo "To automatically create DNS records in Cloudflare, we need your:"
echo "1. Cloudflare API token (with DNS edit permissions)"
echo "2. Zone ID (for your domain)"
echo ""
echo "Please add these to your .env file:"
echo "# Cloudflare API credentials"
echo "CLOUDFLARE_API_TOKEN=your_api_token_here"
echo "CLOUDFLARE_ZONE_ID=your_zone_id_here"
echo ""
echo "You can find these in your Cloudflare dashboard:"
echo "- API Token: https://dash.cloudflare.com/profile/api-tokens"
echo "- Zone ID: In the overview page of your domain"