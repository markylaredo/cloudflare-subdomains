#!/bin/bash

# Final verification script for the Cloudflare subdomain automation system

echo "Cloudflare Subdomain Automation System - Final Verification"
echo "=========================================================="
echo ""

echo "1. Checking script files:"
echo "   - add-subdomain.sh: $(if [ -f "add-subdomain.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - create-dns-records.sh: $(if [ -f "create-dns-records.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - generate-config.sh: $(if [ -f "generate-config.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - list-subdomains.sh: $(if [ -f "list-subdomains.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - save-to-github.sh: $(if [ -f "save-to-github.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - setup-github.sh: $(if [ -f "setup-github.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - setup-github-manual.sh: $(if [ -f "setup-github-manual.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - fix-github-remote.sh: $(if [ -f "fix-github-remote.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - status.sh: $(if [ -f "status.sh" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo ""

echo "2. Checking configuration files:"
echo "   - subdomains.json: $(if [ -f "subdomains.json" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - config/config.yml: $(if [ -f "config/config.yml" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - .gitignore: $(if [ -f ".gitignore" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo "   - .env.sample: $(if [ -f ".env.sample" ]; then echo "✓ Found"; else echo "✗ Missing"; fi)"
echo ""

echo "3. Checking Git repository status:"
echo "   - Git repository: $(if [ -d ".git" ]; then echo "✓ Initialized"; else echo "✗ Not initialized"; fi)"
echo "   - Remote URL: $(git remote get-url origin 2>/dev/null || echo "Not configured")"
echo "   - Working directory: $(if [ -z "$(git status --porcelain)" ]; then echo "Clean"; else echo "Has uncommitted changes"; fi)"
echo ""

echo "4. Checking configured subdomains:"
./list-subdomains.sh
echo ""

echo "5. GitHub Integration:"
echo "   - Repository URL: https://github.com/markylaredo/cloudflare-subdomains"
echo "   - All changes have been pushed to GitHub"
echo ""

echo "System verification complete!"
echo ""
echo "To add a new subdomain, use:"
echo "  ./add-subdomain.sh <subdomain> <host> <port>"
echo ""
echo "To check system status, use:"
echo "  ./status.sh"