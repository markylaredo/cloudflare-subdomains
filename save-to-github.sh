#!/bin/bash

# Script to automatically commit and push configuration changes to GitHub

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if there are any changes to commit
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit"
    exit 0
fi

# Add all changes
git add .

# Create commit message with timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
commit_message="Update subdomain configuration - $timestamp"

# Commit changes
git commit -m "$commit_message"

# Push to remote repository (if configured)
if git remote get-url origin > /dev/null 2>&1; then
    echo "Pushing changes to GitHub..."
    git push origin master 2>/dev/null || git push origin main 2>/dev/null || echo "Failed to push to remote repository"
else
    echo "No remote repository configured. Changes committed locally."
    echo "To set up GitHub integration, run:"
    echo "git remote add origin <your-github-repo-url>"
    echo "git push -u origin master"
fi

echo "Configuration saved to git repository"