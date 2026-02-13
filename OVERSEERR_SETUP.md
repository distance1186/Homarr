# Overseerr Setup Guide

**Overseerr** is a request management and media discovery tool for Plex. It allows users to request movies and TV shows, which can then be automatically downloaded and added to your Plex library.

---

## What is Overseerr?

Overseerr provides:
- **Media Requests**: Users can search and request movies/TV shows
- **Plex Integration**: Connects to your Plex server to check existing media
- **User Management**: Different user roles and permissions
- **Notifications**: Discord, Slack, email notifications for new requests
- **Auto-approval**: Optional automatic approval for trusted users
- **4K Support**: Separate 4K quality requests

---

## Deployment on Ubuntu VM

### Current Setup

Overseerr has been added to your docker-compose.yml alongside Homarr:

```yaml
services:
  homarr:
    # ... existing homarr config

  overseerr:
    container_name: overseerr
    image: lscr.io/linuxserver/overseerr:latest
    restart: unless-stopped
    volumes:
      - ./overseerr/config:/config
    ports:
      - '5055:5055'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ:-America/New_York}
```

### Access URLs

- **From anywhere on network:** http://172.16.10.216:5055
- **From Ubuntu VM:** http://localhost:5055

---

## Installation Steps

### Step 1: Transfer Updated docker-compose.yml

From Windows PowerShell:

```powershell
# Transfer the updated docker-compose.yml to the VM
scp D:\Projects\Homarr\docker-compose.yml homarr@172.16.10.216:~/Homarr/
```

### Step 2: Create Overseerr Directory

SSH into the VM and create the config directory:

```powershell
ssh homarr@172.16.10.216
```

Then in the VM:

```bash
cd ~/Homarr
mkdir -p overseerr/config
```

### Step 3: Start Overseerr

```bash
cd ~/Homarr
docker compose up -d overseerr
```

This will:
- Pull the Overseerr image (may take a few minutes)
- Create and start the overseerr container
- Make it accessible on port 5055

### Step 4: Verify it's Running

```bash
docker compose ps
```

You should see both `homarr` and `overseerr` containers running.

---

## Initial Configuration

### Access Overseerr

Open in your browser: http://172.16.10.216:5055

### Setup Wizard

1. **Sign In with Plex**
   - Click "Sign in with Plex"
   - Authorize Overseerr to access your Plex account
   - This connects Overseerr to your Plex server

2. **Configure Plex Server**
   - Overseerr will auto-detect your Plex server
   - Select your Plex server (KNHOST)
   - Choose which Plex libraries to sync:
     - Movies library (D:\Movies)
     - TV Shows library (D:\TV)
   - Click "Continue"

3. **Configure Download Clients** (Optional for now)
   - You can skip this initially
   - Later you can integrate with:
     - Radarr (for movies)
     - Sonarr (for TV shows)
     - These handle automatic downloading

4. **User Settings**
   - Set display name
   - Configure notifications (optional)
   - Set your user as admin

5. **Finish Setup**
   - Review settings
   - Click "Finish Setup"

---

## Plex Integration

### What You Need

- **Plex Server:** Already running on KNHOST (port 32400)
- **Plex Token:** Obtained during Overseerr setup (handled automatically when you sign in with Plex)
- **Library Access:** Overseerr needs access to your Plex libraries

### Configuration

1. **Plex Server URL:** `http://KNHOST:32400` (or use server IP)
2. **Libraries to Sync:**
   - Movies (includes your 15 anime movies)
   - TV Shows (includes your 9 anime TV shows)

### Sync Behavior

- Overseerr periodically syncs with Plex to check for new media
- When media is requested and already exists in Plex, it shows as "Available"
- Users can see what's already in your library before requesting

---

## User Management

### Admin Features

As admin, you can:
- Approve/deny requests
- Manage users and permissions
- Configure notification settings
- View request history
- Set quotas for users

### Creating Users

**Option 1: Plex Users** (Recommended)
- Users sign in with their Plex account
- Automatically inherits Plex user permissions
- Best for users who already have Plex access

**Option 2: Local Users**
- Create local accounts in Overseerr
- Good for users who don't need direct Plex access
- Can be given Plex access separately

### User Permissions

- **Admin:** Full access to all settings
- **Manage Requests:** Can approve/deny requests
- **Request:** Can only submit requests (default)
- **Auto-approve:** Requests automatically approved (for trusted users)

---

## Request Workflow

### How Users Request Media

1. User logs into Overseerr
2. Searches for movie or TV show
3. Clicks "Request"
4. Selects quality (if configured)
5. Adds optional message
6. Submits request

### How You Handle Requests

**Manual Download:**
1. View pending requests in Overseerr
2. Approve the request
3. Manually download the media
4. Place in D:\To be sorted
5. Run `Sort-NewDownloads.ps1` script (or wait for scheduled task)
6. Plex automatically detects new media
7. Overseerr marks request as "Available" after Plex sync

**With Radarr/Sonarr (Advanced - Future Enhancement):**
1. User submits request
2. Overseerr automatically sends to Radarr/Sonarr
3. Radarr/Sonarr downloads media
4. Media auto-sorted to correct folder
5. Plex picks up new media
6. User gets notification when available

---

## Notifications

### Available Notification Types

- **Discord:** Webhook integration
- **Slack:** Webhook integration
- **Email:** SMTP configuration
- **Telegram:** Bot integration
- **Pushover:** Mobile notifications
- **Webhooks:** Custom integrations

### Notification Events

- New request submitted
- Request approved
- Request declined
- Media available
- Media failed

### Basic Email Setup

Settings → Notifications → Email:
1. Enable Email notifications
2. SMTP Host: (your email server)
3. Port: 587 (TLS) or 465 (SSL)
4. Username/Password: (your email credentials)
5. From address: notifications@yourdomain.com
6. Test notification to verify

---

## Integration with Homarr

### Add Overseerr to Homarr Dashboard

1. Go to Homarr: http://172.16.10.216:7575
2. Click "Edit Mode"
3. Click "Add Service"
4. Configure:
   - **Name:** Overseerr
   - **URL:** `http://172.16.10.216:5055`
   - **Icon:** Search "Overseerr"
   - **Category:** Media

### Overseerr Widget (Optional)

Homarr may support Overseerr widgets showing:
- Pending requests count
- Recent requests
- Quick access to request media

Check Homarr widget library for Overseerr integration options.

---

## Folder Structure

On the VM, your setup looks like:

```
~/Homarr/
├── docker-compose.yml
├── .env
├── homarr/
│   ├── configs/
│   ├── icons/
│   └── data/
└── overseerr/
    └── config/       # Overseerr configuration and database
```

---

## Common Configuration Options

### Settings → General

- **Application Title:** Customize the name
- **Display Language:** Set language preference
- **Discover Region:** Default region for media discovery
- **Hide Available Media:** Don't show already-available content in search

### Settings → Plex

- **Server:** Your Plex server connection
- **Libraries:** Which libraries to scan
- **Scan Interval:** How often to sync with Plex (default: 6 hours)

### Settings → Users

- **Enable Local Sign-in:** Allow local accounts
- **Enable New Plex Sign-ins:** Auto-create accounts for new Plex users
- **Default Permissions:** What new users can do
- **Enable User Request Quotas:** Limit requests per user

### Settings → Requests

- **Auto-approve:** Automatically approve all requests (not recommended)
- **Days to Keep Requests:** Retention period for completed requests

---

## Advanced Features (Future)

### Integration with Download Automation

For fully automated requests, you can add:

**Radarr** (Movie management):
- Automatically download requested movies
- Quality profiles and naming conventions
- Integration with download clients

**Sonarr** (TV show management):
- Automatically download requested TV episodes
- Season monitoring and tracking
- Episode scheduling

**Download Clients:**
- Transmission, qBittorrent, Deluge, etc.
- Handle actual file downloads

**Setup would require:**
1. Deploy Radarr/Sonarr in Docker
2. Configure download client
3. Connect to Overseerr
4. Set up media folders and quality profiles

---

## Maintenance

### Update Overseerr

```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose pull overseerr
docker compose up -d overseerr
```

### View Logs

```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose logs -f overseerr
```

### Restart Overseerr

```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose restart overseerr
```

### Backup Configuration

```bash
ssh homarr@172.16.10.216
cd ~/Homarr
tar -czf overseerr-backup-$(date +%Y%m%d).tar.gz overseerr/
```

---

## Troubleshooting

### Can't Connect to Plex

- Verify Plex is running on KNHOST
- Check Plex URL is correct: `http://KNHOST:32400` (replace with IP if needed)
- Ensure Plex is accessible from the Ubuntu VM network
- Verify Plex token is valid

### Overseerr Not Starting

```bash
# Check logs
docker compose logs overseerr

# Check container status
docker compose ps

# Restart the container
docker compose restart overseerr
```

### Port 5055 Already in Use

If port 5055 is already taken:

Edit docker-compose.yml:
```yaml
ports:
  - '5056:5055'  # Use port 5056 instead
```

Then restart:
```bash
docker compose up -d overseerr
```

### Media Not Showing as Available

- Check Plex sync is running: Settings → Plex → Sync Libraries
- Manually trigger sync if needed
- Verify library paths match Plex configuration
- Check Overseerr has access to all Plex libraries

---

## Security Considerations

### Network Access

- Overseerr is on internal network only (172.16.10.216)
- Not exposed to internet (good for security)
- Access from any device on your local network

### User Access

- Only allow trusted users
- Use request quotas to prevent abuse
- Review and approve requests before processing
- Monitor request history for suspicious activity

### Plex Token Security

- Never share your Plex token publicly
- Token stored securely in Overseerr config
- Backup configuration files securely

---

## Quick Reference Commands

### Access Overseerr
```
http://172.16.10.216:5055
```

### Start/Stop/Restart
```bash
ssh homarr@172.16.10.216
cd ~/Homarr

# Start
docker compose up -d overseerr

# Stop
docker compose stop overseerr

# Restart
docker compose restart overseerr

# View logs
docker compose logs -f overseerr
```

### Update
```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose pull overseerr
docker compose up -d overseerr
```

---

## Next Steps

After Overseerr is running:

1. ☐ Complete initial setup wizard
2. ☐ Connect to Plex server
3. ☐ Sync Plex libraries
4. ☐ Configure user permissions
5. ☐ Set up notifications (optional)
6. ☐ Add Overseerr to Homarr dashboard
7. ☐ Test request workflow
8. ☐ Invite users (optional)
9. ☐ Consider Radarr/Sonarr for automation (future)

---

## Resources

- **Overseerr Docs:** https://docs.overseerr.dev
- **Docker Image:** https://github.com/linuxserver/docker-overseerr
- **Your Setup:**
  - VM: 172.16.10.216
  - Port: 5055
  - Plex: KNHOST:32400

---

**Created:** February 13, 2026  
**Overseerr URL:** http://172.16.10.216:5055  
**Status:** Ready to deploy
