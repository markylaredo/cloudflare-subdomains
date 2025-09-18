#!/bin/bash

# Manual GitHub Setup Script
# Use this script if you prefer to set up GitHub integration manually

echo "Manual GitHub Integration Setup"
echo "============================="
echo ""

echo "Step 1: Create a new repository on GitHub"
echo "----------------------------------------"
echo "1. Go to https://github.com/new"
echo "2. Enter a repository name (e.g., 'cloudflare-subdomains')"
echo "3. Choose Public or Private"
echo "4. Do NOT initialize with a README"
echo "5. Click 'Create repository'"
echo ""
read -p "Press Enter when you've created the repository..."

echo ""
echo "Step 2: Configure the remote repository"
echo "--------------------------------------"
read -p "Enter your GitHub username: " github_username
read -p "Enter your repository name: " repo_name

if [ -z "$github_username" ] || [ -z "$repo_name" ]; then
    echo "Error: Username and repository name are required"
    echo "Let's try again..."
    read -p "Enter your GitHub username: " github_username
    read -p "Enter your repository name: " repo_name
    
    if [ -z "$github_username" ] || [ -z "$repo_name" ]; then
        echo "Error: Username and repository name are still required"
        echo "You can manually set up the remote repository later with:"
        echo "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
        echo "git branch -M main"
        echo "git push -u origin main"
        exit 1
    fi
fi

# Set up remote repository
echo "Setting up remote repository..."
git remote add origin "https://github.com/$github_username/$repo_name.git"

echo ""
echo "Step 3: Push to GitHub"
echo "----------------------"
echo "Setting branch name to main and pushing..."
git branch -M main
git push -u origin main

echo ""
echo "GitHub integration set up successfully!"
echo "Your subdomain configuration is now being saved to https://github.com/$github_username/$repo_name"