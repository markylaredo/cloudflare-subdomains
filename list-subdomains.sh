#!/bin/bash

# Script to list all configured subdomains

echo "Configured Subdomains:"
echo "===================="

python3 -c "
import json

# Read subdomains from JSON
try:
    with open('subdomains.json', 'r') as f:
        data = json.load(f)
    
    if not data['subdomains']:
        print('No subdomains configured.')
    else:
        for subdomain in data['subdomains']:
            print(f'{subdomain[\"name\"]}.solodevmark.com -> http://{subdomain[\"host\"]}:{subdomain[\"port\"]}')
except FileNotFoundError:
    print('subdomains.json file not found.')
except Exception as e:
    print(f'Error reading subdomains: {e}')
"