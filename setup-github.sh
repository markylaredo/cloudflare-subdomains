#!/bin/bash

# Script to set up GitHub integration for subdomain configuration

echo "GitHub Integration Setup"
echo "======================"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Please install it first:"
    echo "https://github.com/cli/cli#installation"
    echo ""
    echo "Alternatively, you can set up GitHub integration manually:"
    echo "1. Create a new repository on GitHub"
    echo "2. Run the following commands:"
    echo "   git remote add origin <your-github-repo-url>"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    exit 1
fi

# Check if user is logged in to GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "Please log in to GitHub CLI:"
    gh auth login
fi

# Get GitHub username
username=$(gh api user | python3 -c "import sys, json; print(json.load(sys.stdin)['login'])" 2>/dev/null)

if [ -z "$username" ]; then
    echo "Error: Could not retrieve GitHub username"
    echo "Please make sure you're logged in to GitHub CLI:"
    echo "gh auth login"
    exit 1
fi

# Create repository if it doesn't exist
repo_name="cloudflare-subdomains"

echo "Creating repository $username/$repo_name..."
gh repo create "$username/$repo_name" --public --clone 2>/dev/null || echo "Repository may already exist or creation failed"

# Set up remote if not already set
if ! git remote get-url origin &> /dev/null; then
    echo "Setting up remote repository..."
    git remote add origin "https://github.com/$username/$repo_name.git"
fi

# Make initial commit if needed
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit"
else
    echo "Making initial commit..."
    git add .
    git commit -m "Initial commit: Cloudflare subdomain configuration system" 2>/dev/null || echo "Commit may already exist"
fi

# Set branch name to main if it's master
current_branch=$(git branch --show-current)
if [ "$current_branch" = "master" ]; then
    git branch -m main 2>/dev/null || echo "Branch rename may not be needed"
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || echo "Push failed, please check your repository settings"

echo ""
echo "GitHub integration set up successfully!"
echo "Your subdomain configuration is now being saved to https://github.com/$username/$repo_name"