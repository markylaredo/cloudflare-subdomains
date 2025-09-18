#!/bin/bash

# Script to show the current status of the subdomain configuration repository

echo "Cloudflare Subdomain Configuration Status"
echo "========================================"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Show current branch
echo "Current branch: $(git branch --show-current)"
echo ""

# Show git status
echo "Repository status:"
if [ -z "$(git status --short)" ]; then
    echo "Working directory is clean"
else
    git status --short
fi
echo ""

# Show last commit
echo "Last commit:"
git log -1 --pretty=format:"%h - %an, %ar : %s"
echo ""
echo ""

# Show configured subdomains
echo "Configured subdomains:"
./list-subdomains.sh
echo ""

# Show remote repository (if configured)
if git remote get-url origin > /dev/null 2>&1; then
    echo "Remote repository:"
    git remote -v | grep origin
    echo ""
    echo "To manually push changes to GitHub:"
    echo "git push origin $(git branch --show-current)"
else
    echo "No remote repository configured"
    echo ""
    echo "To set up GitHub integration:"
    echo "  Automated: ./setup-github.sh (requires GitHub CLI)"
    echo "  Manual:    ./setup-github-manual.sh"
    echo "  Direct:    git remote add origin <your-github-repo-url>"
fi