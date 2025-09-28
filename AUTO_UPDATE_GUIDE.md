# Automatic Subdomain Configuration Update Guide

This guide explains how to use the auto-update functionality for your Cloudflare tunnel configuration.

## What does this do?

The auto-update system monitors your `subdomains.json` file for any changes and automatically:
1. Updates the Cloudflare tunnel configuration (`config.yml`)
2. Restarts the cloudflared service to apply changes
3. Saves the configuration to GitHub for backup

## Two Methods Available

The system provides two methods for automatic updates:

### Method 1: Real-time Monitoring (Recommended - Requires inotify-tools)
- Monitors `subdomains.json` in real-time
- Automatically updates configuration when changes are detected
- Requires `inotify-tools` package to be installed

### Method 2: Manual/Periodic Updates
- Checks for changes and updates configuration manually or via cron
- Does not require additional packages
- Can be scheduled to run periodically

## Method 1: Real-time Monitoring (Requires inotify-tools)

### Prerequisites
Before using the real-time auto-update script, ensure you have:

1. **inotify-tools installed** (for file monitoring):
   ```bash
   # On Ubuntu/Debian:
   sudo apt-get install inotify-tools
   
   # On CentOS/RHEL:
   sudo yum install inotify-tools
   ```

2. Make sure your `subdomains.json` and `config/config.yml` files exist

### How to Use Real-time Monitoring

#### 1. Start the Auto-Update Monitor

Run the auto-update script in the background:

```bash
# Start the monitor in the background
./auto-update-config.sh &

# Or use nohup to keep it running after terminal closes:
nohup ./auto-update-config.sh > auto-update.log 2>&1 &
```

## Method 2: Manual/Periodic Updates (No additional packages needed)

### How to Use Manual Updates

#### 1. Run Manual Updates
Run the manual update script whenever you make changes to `subdomains.json`:

```bash
./manual-update-config.sh
```

The script will:
- Compare the current `subdomains.json` with the last known version
- Only update if changes are detected
- Restart the cloudflared service if updates are made

#### 2. Schedule Periodic Updates (Optional)
You can also set up a cron job to periodically check for updates:

```bash
# Edit your crontab:
crontab -e

# Add this line to check every 5 minutes:
*/5 * * * * cd /home/solodevmark/containers/cloudflare && ./manual-update-config.sh
```

### 2. Modify Your Subdomain Configuration

Once the monitor is running, you can edit your `subdomains.json` file:

```json
{
  "subdomains": [
    {
      "name": "deploy",
      "host": "192.168.8.152",
      "port": 3000
    },
    {
      "name": "infatrack",
      "host": "192.168.8.152",
      "port": 3001
    },
    {
      "name": "testapp",
      "host": "192.168.8.152",
      "port": 3002
    }
  ]
}
```

### 3. Changes are Applied Automatically

When you save changes to `subdomains.json`, the system will:
- Generate a new `config/config.yml` with updated routing rules
- Restart the cloudflared service in the Docker container
- Commit and push changes to GitHub

## Example Usage

### Adding a New Subdomain
1. Add a new entry to `subdomains.json`:
   ```json
   {
     "name": "newapp",
     "host": "192.168.8.152",
     "port": 3003
   }
   ```

2. Save the file - the system will automatically update the configuration

### Updating an Existing Subdomain
1. Change the host or port in `subdomains.json`:
   ```json
   {
     "name": "infatrack",
     "host": "192.168.8.152",  // Updated IP
     "port": 8080             // Updated port
   }
   ```

2. Save the file - the system will automatically update the configuration

### Removing a Subdomain
1. Remove the entry from `subdomains.json`
2. Save the file - the system will automatically update the configuration

## Important Notes

1. **Network Changes**: If your network IP changes, you'll need to update all your subdomain entries from the old IP to the new IP.

2. **Service Availability**: Remember that the tunnel only works if you have an actual service running on the specified host/port combination.

3. **DNS Records**: The auto-update script only updates the tunnel configuration. DNS records are managed separately by the `create-dns-records.sh` script.

4. **Monitoring**: Check the log file (`auto-update.log`) to see when updates occur and if there are any errors.

## Managing the Monitor Process

### Check if the monitor is running:
```bash
ps aux | grep auto-update-config.sh
```

### Stop the monitor:
```bash
pkill -f auto-update-config.sh
```

### View the logs:
```bash
tail -f auto-update.log
```

## Troubleshooting

### If the monitor doesn't detect changes:
- Make sure you're saving the file properly (some editors create temporary files)
- Check if inotify-tools is properly installed
- Verify the log file for any error messages

### If the service doesn't restart:
- Check if Docker is running
- Ensure the container name 'solodevmark' is correct
- Manually restart with: `docker restart solodevmark`

### If you get permission errors:
- Make sure the script is executable: `chmod +x auto-update-config.sh`
- Check that you have write permissions to the config directory