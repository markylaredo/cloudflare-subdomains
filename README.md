# Automatic Cloudflare Subdomain Registration

This system allows you to automatically register new subdomains with your Cloudflare tunnel by simply adding them to a configuration file or using a command-line script.

## Prerequisites

Before you can automatically create DNS records, you need to set up Cloudflare API credentials.

### Automated Setup (Recommended)

Run the setup script:
```bash
./setup-cloudflare-credentials.sh
```

This script will guide you through creating an API token and finding your Zone ID.

### Manual Setup

1. Create an API token with DNS edit permissions:
   - Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
   - Create a token with DNS edit permissions for your domain

2. Find your Zone ID:
   - In the Cloudflare dashboard, go to your domain's overview page
   - The Zone ID is listed in the right sidebar

3. Add these to your `.env` file:
   ```bash
   # Cloudflare API credentials
   CLOUDFLARE_API_TOKEN=your_api_token_here
   CLOUDFLARE_ZONE_ID=your_zone_id_here
   ```

## GitHub Integration

The system automatically saves your configuration to GitHub for version control and backup.

### Automated Setup (Recommended)

Run the setup script:
```bash
./setup-github.sh
```

This script requires the GitHub CLI to be installed. If you don't have it installed, you can:

1. Install the GitHub CLI: https://github.com/cli/cli#installation
2. Or use the manual setup method below

### Manual Setup (Alternative)

If you prefer to set up GitHub integration manually or don't want to install the GitHub CLI:

```bash
./setup-github-manual.sh
```

This script will guide you through:
1. Creating a new repository on GitHub
2. Configuring the remote repository
3. Pushing your current configuration to GitHub

### Manual Setup (Direct)

You can also set up GitHub integration directly:

1. Create a new repository on GitHub:
   - Go to https://github.com/new
   - Enter "cloudflare-subdomains" as the repository name
   - Choose Public or Private
   - Make sure to NOT initialize with a README
   - Click "Create repository"

2. Run the following commands:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/cloudflare-subdomains.git
   git branch -M main
   git push -u origin main
   ```

### Fixing Remote URL Issues

If you see a malformed remote URL (missing username), you can fix it with:
```bash
./fix-github-remote.sh
```

This script will:
1. Check the current remote URL
2. Help you fix it if it's malformed
3. Update it with your correct GitHub username

### Pushing Changes to GitHub

After setting up the remote repository, push your changes:
```bash
git push -u origin main
```

### How It Works

Every time you add a subdomain or modify the configuration:
1. Changes are automatically committed to the git repository
2. If a remote repository is configured, changes are pushed to GitHub
3. All changes are timestamped for easy tracking

You can also manually save changes:
```bash
./save-to-github.sh
```

### Monitoring Repository Status

Check the current status of your repository:
```bash
./status.sh
```

This script shows:
- Current branch
- Repository status (changes, untracked files)
- Last commit information
- Configured subdomains
- Remote repository information

### System Verification

To verify that all components of the system are working correctly:
```bash
./verify-system.sh
```

This script checks:
- All required script files
- Configuration files
- Git repository status
- Configured subdomains
- GitHub integration

## How it works

1. The `subdomains.json` file contains a list of all your subdomains and their corresponding services
2. The `generate-config.sh` script reads this file and generates the appropriate `config.yml` for cloudflared
3. The `add-subdomain.sh` script provides a simple way to add new subdomains
4. The `create-dns-records.sh` script automatically creates DNS records in Cloudflare
5. The `list-subdomains.sh` script shows all currently configured subdomains
6. The `Makefile` provides convenient commands for common operations

## Adding new subdomains

### Method 1: Using the add-subdomain script (recommended)

```bash
./add-subdomain.sh <subdomain> <host> <port>
```

Example:
```bash
./add-subdomain.sh infatrack 192.168.10.153 3001
```

This will:
1. Add the subdomain to your configuration
2. Generate the updated tunnel configuration
3. Restart the cloudflared service
4. Automatically create the DNS record in Cloudflare

### Method 2: Using Make (recommended)

```bash
make add name=<subdomain> host=<host> port=<port>
```

Example:
```bash
make add name=infatrack host=192.168.10.153 port=3001
```

### Method 3: Manually editing subdomains.json

Edit the `subdomains.json` file and add your new subdomain to the list:

```json
{
  "subdomains": [
    {
      "name": "deploy",
      "host": "192.168.10.153",
      "port": 3000
    },
    {
      "name": "infatrack",
      "host": "192.168.10.153",
      "port": 3001
    }
  ]
}
```

Then run the generate-config script:
```bash
./generate-config.sh
```

And create the DNS records:
```bash
./create-dns-records.sh
```

Or with Make:
```bash
make generate
```

## Managing DNS records

To create DNS records for all subdomains in your configuration:
```bash
./create-dns-records.sh
```

To create a DNS record for a specific subdomain:
```bash
./create-dns-records.sh <subdomain>
```

## Listing configured subdomains

To see all currently configured subdomains:

```bash
./list-subdomains.sh
```

Or with Make:
```bash
make list
```

## How it works behind the scenes

1. When you add a new subdomain, the system updates the `config.yml` file with the new ingress rule
2. The cloudflared service is automatically restarted to apply the changes
3. Your new subdomain will be available immediately

## Prerequisites

- Python 3 must be installed
- The cloudflared service should be running as a Docker container named "solodevmark"
- The tunnel credentials and configuration files should be in place

## Troubleshooting

If the subdomain doesn't work after adding it:

1. Check that the service is running on the specified host and port
2. Verify that the cloudflared container was restarted successfully
3. Check the cloudflared logs for any errors:
   ```bash
   docker logs solodevmark
   ```