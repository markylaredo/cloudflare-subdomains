#!/bin/bash

# Script to fix the GitHub remote URL

echo "Fix GitHub Remote URL"
echo "===================="
echo ""

# Get current remote URL
current_url=$(git remote get-url origin 2>/dev/null)

if [ -z "$current_url" ]; then
    echo "No remote repository configured"
    echo "Please set up GitHub integration using:"
    echo "  ./setup-github.sh (requires GitHub CLI)"
    echo "  ./setup-github-manual.sh (interactive manual setup)"
    exit 1
fi

echo "Current remote URL: $current_url"

# Check if URL is malformed (missing username or has double slash)
if [[ $current_url == *"github.com//" ]] || [[ $current_url == "https://github.com//cloudflare-subdomains.git" ]]; then
    echo ""
    echo "Remote URL appears to be malformed (missing username)"
    # Use default username if not provided
    github_username="markylaredo"
    echo "Using default username: $github_username"
    
    # Set the correct remote URL
    new_url="https://github.com/$github_username/cloudflare-subdomains.git"
    echo "Setting remote URL to: $new_url"
    git remote set-url origin "$new_url"
    
    echo "Remote URL updated successfully!"
else
    echo "Remote URL appears to be correct"
fi

echo ""
echo "Current remote URLs:"
git remote -v