#!/bin/bash

# Script to help set up Cloudflare API credentials

echo "Cloudflare API Credentials Setup"
echo "=============================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    touch .env
fi

# Check if credentials are already set
if grep -q "CLOUDFLARE_API_TOKEN" .env && grep -q "CLOUDFLARE_ZONE_ID" .env; then
    echo "Cloudflare API credentials already exist in .env file."
    echo "Current values:"
    grep "CLOUDFLARE_API_TOKEN\|CLOUDFLARE_ZONE_ID" .env
    echo ""
    read -p "Do you want to update them? (y/N): " update
    if [[ ! $update =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

echo ""
echo "To set up Cloudflare API credentials, you'll need:"
echo "1. An API token with DNS edit permissions"
echo "2. Your Zone ID"
echo ""
echo "Instructions:"
echo "1. Go to https://dash.cloudflare.com/profile/api-tokens"
echo "2. Create a token with DNS edit permissions for your domain"
echo "3. Copy the API token"
echo "4. Find your Zone ID in the overview page of your domain"
echo ""
read -p "Enter your Cloudflare API token: " api_token
read -p "Enter your Cloudflare Zone ID: " zone_id

# Remove existing credentials if they exist
sed -i '/CLOUDFLARE_API_TOKEN/d' .env
sed -i '/CLOUDFLARE_ZONE_ID/d' .env

# Add new credentials
echo "CLOUDFLARE_API_TOKEN=$api_token" >> .env
echo "CLOUDFLARE_ZONE_ID=$zone_id" >> .env

echo ""
echo "Cloudflare API credentials have been added to .env file."
echo "You can now automatically create DNS records for your subdomains!"