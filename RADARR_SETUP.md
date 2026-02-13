# Radarr Setup Guide - Full Movie Automation

**Radarr** is an automated movie collection manager. It monitors multiple RSS feeds for new movies, downloads them via download clients, and organizes them in your media library.

---

## What is Radarr?

Radarr provides:
- **Automated Movie Downloading**: Monitors release schedules and quality profiles
- **Quality Management**: Download the best quality version available
- **Naming & Organization**: Automatically renames and organizes files
- **Integration with Overseerr**: Automatically processes movie requests
- **Library Management**: Tracks your entire movie collection
- **Upgrade Management**: Automatically upgrades to better quality versions

---

## Complete Automation Pipeline

With Homarr + Overseerr + Radarr, here's your full workflow:

1. **User** requests a movie in Overseerr
2. **Overseerr** sends request to Radarr
3. **Radarr** searches for the movie and downloads it
4. **Radarr** moves completed download to `D:\Movies`
5. **Plex** automatically detects and adds the movie
6. **Overseerr** marks request as "Available"
7. **User** gets notification

---

## Deployment on Ubuntu VM

### Current Setup

Radarr has been added to your docker-compose.yml:

```yaml
services:
  homarr:
    # ... existing homarr config

  overseerr:
    # ... existing overseerr config

  radarr:
    container_name: radarr
    image: lscr.io/linuxserver/radarr:latest
    restart: unless-stopped
    volumes:
      - ./radarr/config:/config
      - ./downloads:/downloads
      - ./media/movies:/movies
    ports:
      - '7878:7878'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ:-America/New_York}
```

### Access URLs

- **From anywhere on network:** http://172.16.10.216:7878
- **From Ubuntu VM:** http://localhost:7878

---

## Installation Steps

### Step 1: Transfer Updated docker-compose.yml

From Windows PowerShell:

```powershell
# Transfer the updated docker-compose.yml to the VM
scp D:\Projects\Homarr\docker-compose.yml homarr@172.16.10.216:~/Homarr/
```

### Step 2: Create Radarr Directories

SSH into the VM:

```powershell
ssh homarr@172.16.10.216
```

Then in the VM:

```bash
cd ~/Homarr
mkdir -p radarr/config
mkdir -p downloads
mkdir -p media/movies
```

### Step 3: Start Radarr

```bash
cd ~/Homarr
docker compose up -d radarr
```

This will:
- Pull the Radarr image (may take a few minutes)
- Create and start the radarr container
- Make it accessible on port 7878

### Step 4: Verify it's Running

```bash
docker compose ps
```

You should see `homarr`, `overseerr`, and `radarr` containers running.

---

## Initial Configuration

### Access Radarr

Open in your browser: http://172.16.10.216:7878

### Setup Wizard

1. **Authentication** (Optional but Recommended)
   - Settings → General → Security
   - Enable authentication
   - Set username and password
   - Protects Radarr from unauthorized access

2. **Media Management Settings**
   - Settings → Media Management
   - **Root Folder:** Add `/movies` (this maps to `~/Homarr/media/movies` in VM)
   - **File Naming:** Enable rename movies
   - **Naming Format:** Use standard format like `{Movie Title} ({Release Year})`
   - **Replace Illegal Characters:** Enable

---

## Connecting to KNHOST Plex/Movies Folder

**Important**: Radarr is running in a Docker container on the Ubuntu VM (172.16.10.216), but your movies need to end up on KNHOST (Windows Server) at `D:\Movies` for Plex to see them.

### Option 1: SMB/CIFS Mount (Recommended)

Mount KNHOST's D:\Movies folder to the Ubuntu VM:

**On Windows Server (KNHOST):**

```powershell
# Create an SMB share for the Movies folder
New-SmbShare -Name "Movies" -Path "D:\Movies" -FullAccess "Everyone"
New-SmbShare -Name "Downloads" -Path "D:\To be sorted" -FullAccess "Everyone"
```

**On Ubuntu VM:**

```bash
# Install CIFS utilities
sudo apt-get install cifs-utils -y

# Create mount points
sudo mkdir -p /mnt/knhost-movies
sudo mkdir -p /mnt/knhost-downloads

# Mount the shares (replace <KNHOST-IP> with actual IP)
sudo mount -t cifs //<KNHOST-IP>/Movies /mnt/knhost-movies -o username=Administrator,uid=1000,gid=1000
sudo mount -t cifs //<KNHOST-IP>/Downloads /mnt/knhost-downloads -o username=Administrator,uid=1000,gid=1000

# Make mounts persistent (add to /etc/fstab)
echo "//<KNHOST-IP>/Movies /mnt/knhost-movies cifs username=Administrator,password=<PASSWORD>,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab
echo "//<KNHOST-IP>/Downloads /mnt/knhost-downloads cifs username=Administrator,password=<PASSWORD>,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab
```

Then update docker-compose.yml volumes:

```yaml
radarr:
  volumes:
    - ./radarr/config:/config
    - /mnt/knhost-downloads:/downloads
    - /mnt/knhost-movies:/movies
```

### Option 2: Post-Processing Script

Create a script that automatically moves completed downloads from VM to KNHOST:

```bash
#!/bin/bash
# ~/Homarr/sync-to-knhost.sh
rsync -avz ~/Homarr/media/movies/ Administrator@<KNHOST-IP>:/d/Movies/
```

Run this as a cron job or manually after downloads complete.

### Option 3: Run Radarr Directly on KNHOST

If you prefer, you can install Radarr on KNHOST Windows Server instead of in the VM. This gives direct access to D:\Movies.

---

## Download Client Setup

Radarr needs a download client to actually download movies. Popular options:

### Recommended: qBittorrent

Add qBittorrent to your docker-compose.yml:

```yaml
  qbittorrent:
    container_name: qbittorrent
    image: lscr.io/linuxserver/qbittorrent:latest
    restart: unless-stopped
    volumes:
      - ./qbittorrent/config:/config
      - ./downloads:/downloads
    ports:
      - '8080:8080'  # Web UI
      - '6881:6881'  # Torrent port
      - '6881:6881/udp'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ:-America/New_York}
      - WEBUI_PORT=8080
```

**Configure in Radarr:**
1. Settings → Download Clients → Add (+) → qBittorrent
2. **Name:** qBittorrent
3. **Host:** `localhost` (or `qbittorrent` if using Docker networking)
4. **Port:** 8080
5. **Username:** admin
6. **Password:** adminadmin (default, change this!)
7. Test and Save

### Alternative: Transmission, Deluge, SABnzbd, etc.

Radarr supports many download clients. Choose based on your preference.

---

## Indexer Configuration

Indexers are sources where Radarr searches for movies. You need at least one indexer.

### Option 1: Public Indexers (Free, Limited)

**Note:** Public indexers have limitations and may be slower.

Settings → Indexers → Add (+) → Torznab → Generic Torznab

Some free options:
- **RARBG** (if available)
- **YTS** (for smaller files)
- **1337x** (popular)

### Option 2: Private Indexers (Better Quality)

Private trackers require invitations but offer:
- Better quality releases
- Faster downloads
- More reliable availability

Popular private trackers:
- PassThePopcorn
- BroadcasTheNet
- IPTorrents

### Option 3: Jackett (Indexer Proxy)

**Recommended:** Use Jackett to connect to multiple indexers at once.

Add Jackett to docker-compose.yml:

```yaml
  jackett:
    container_name: jackett
    image: lscr.io/linuxserver/jackett:latest
    restart: unless-stopped
    volumes:
      - ./jackett/config:/config
      - ./downloads:/downloads
    ports:
      - '9117:9117'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ:-America/New_York}
```

Access Jackett at: http://172.16.10.216:9117

Then add indexers in Jackett and connect Radarr to Jackett.

---

## Quality Profiles

Configure what quality movies Radarr should download:

Settings → Profiles → Add Quality Profile

**Example Profile:**

**Name:** HD-1080p
**Allowed Qualities:**
- ✓ Bluray-1080p
- ✓ WEB-DL 1080p
- ✓ WEBRip 1080p
- ✗ HDTV-1080p (lower quality)
- ✗ 720p (too low)
- ✗ 4K (too large)

**Upgrade Until:** Bluray-1080p

This means Radarr will:
1. Download any available 1080p version first
2. Automatically upgrade to Bluray-1080p when available

---

## Connecting Overseerr to Radarr

### In Radarr

1. Settings → General → Security
2. Copy the **API Key**

### In Overseerr

1. Settings → Services → Radarr
2. **Enable:** Toggle ON
3. **Server Name:** Radarr
4. **Hostname/IP:** `172.16.10.216`
5. **Port:** 7878
6. **API Key:** (paste from Radarr)
7. **Base URL:** Leave empty
8. **Quality Profile:** Select your profile (e.g., HD-1080p)
9. **Root Folder:** `/movies`
10. **Minimum Availability:** Released (or Announced for early downloads)
11. **Tags:** Optional
12. Test and Save

---

## Testing the Full Pipeline

### Manual Movie Add

1. Go to Radarr: http://172.16.10.216:7878
2. Click "Add New Movie"
3. Search for a movie
4. Select quality profile
5. Select root folder: `/movies`
6. Click "Add Movie"
7. Radarr will search for it and download
8. Monitor: Activity → Queue

### Via Overseerr Request

1. Go to Overseerr: http://172.16.10.216:5055
2. Search for a movie
3. Click "Request"
4. Submit request
5. Request automatically goes to Radarr
6. Radarr downloads the movie
7. Overseerr marks as "Available" once downloaded

---

## File Organization

### Directory Structure

On Ubuntu VM:
```
~/Homarr/
├── docker-compose.yml
├── radarr/
│   └── config/          # Radarr configuration
├── downloads/           # Temporary download location
└── media/
    └── movies/          # Final movie location (or mounted from KNHOST)
```

On KNHOST (Windows Server):
```
D:\Movies\               # Plex library path
D:\To be sorted\         # Alternative download staging area
```

### Naming Convention

Radarr will rename files to a standard format:

```
D:\Movies\
├── The Matrix (1999)\
│   └── The Matrix (1999).mkv
├── Inception (2010)\
│   └── Inception (2010).mkv
└── Interstellar (2014)\
    └── Interstellar (2014).mkv
```

This ensures Plex properly identifies movies.

---

## Media Management Settings

### Recommended Settings

Settings → Media Management:

**File Management:**
- ☑ Rename Movies
- ☑ Replace Illegal Characters
- ☑ Unmonitor Deleted Movies
- ☐ Skip Free Space Check (unless space limited)

**Importing:**
- ☑ Use Hardlinks instead of Copy (saves disk space)
- ☐ Import Extra Files (subs, artwork, etc.) - optional

**Root Folders:**
- `/movies` → Points to final destination

**File Naming:**
- Standard Format: `{Movie Title} ({Release Year})`
- Movie Folder Format: `{Movie Title} ({Release Year})`

---

## Monitoring & Automation

### Automatic Search

Settings → Indexers:
- **RSS Sync Interval:** 15 minutes (how often to check for new releases)

Settings → Movies → Options:
- **Minimum Availability:** Released (download when available)
- **Monitor:** Yes (automatically search for movie)

### Activity Monitoring

Activity → Queue:
- Shows current downloads
- Progress bars
- ETA for completion

Activity → History:
- Shows completed downloads
- Import results
- Any errors

---

## Integration with Homarr Dashboard

### Add Radarr to Homarr

1. Go to Homarr: http://172.16.10.216:7575
2. Click "Edit Mode"
3. Click "Add Service"
4. Configure:
   - **Name:** Radarr
   - **URL:** `http://172.16.10.216:7878`
   - **Icon:** Search "Radarr"
   - **Category:** Media

### Radarr Widget (Optional)

Homarr supports Radarr widgets showing:
- Movie count in library
- Upcoming releases
- Recent downloads
- Queue status

Add widget in Homarr:
1. Edit Mode → Add Widget
2. Select "Radarr"
3. Configure API key from Radarr
4. Position on dashboard

---

## Complete Docker Stack

Your full media automation stack:

```yaml
version: '3.8'

services:
  homarr:          # Dashboard
    ports: ['7575:7575']
  
  overseerr:       # Request management
    ports: ['5055:5055']
  
  radarr:          # Movie automation
    ports: ['7878:7878']
  
  # Optional but recommended:
  jackett:         # Indexer proxy
    ports: ['9117:9117']
  
  qbittorrent:     # Download client
    ports: ['8080:8080']
```

Access URLs:
- Homarr: http://172.16.10.216:7575
- Overseerr: http://172.16.10.216:5055
- Radarr: http://172.16.10.216:7878
- Jackett: http://172.16.10.216:9117
- qBittorrent: http://172.16.10.216:8080

---

## Maintenance

### Update Radarr

```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose pull radarr
docker compose up -d radarr
```

### View Logs

```bash
docker compose logs -f radarr
```

### Restart Radarr

```bash
docker compose restart radarr
```

### Backup Configuration

```bash
cd ~/Homarr
tar -czf radarr-backup-$(date +%Y%m%d).tar.gz radarr/
```

---

## Troubleshooting

### Radarr Can't Access Movie Folder

**Problem:** Permission denied on /movies

**Solution:**
```bash
# On Ubuntu VM
cd ~/Homarr
sudo chown -R 1000:1000 media/movies
chmod -R 755 media/movies
```

### Downloads Not Moving to Movies Folder

**Problem:** Files stay in downloads folder

**Solutions:**
1. Check Radarr → Settings → Media Management → "Move completed downloads" is enabled
2. Verify root folder is configured: Settings → Media Management → Root Folders
3. Check permissions on destination folder
4. View logs: System → Logs for import errors

### Can't Find Any Movies

**Problem:** Radarr searches but finds nothing

**Solutions:**
1. Verify indexers are configured: Settings → Indexers
2. Test indexer connections
3. Check if indexer sites are accessible
4. Try manual search: Movie → Magnifying glass icon

### Movie Downloaded But Plex Doesn't See It

**Problem:** File in D:\Movies but not in Plex

**Solutions:**
1. Verify file is in correct location on KNHOST
2. Check file naming matches Plex requirements
3. Manually trigger Plex library scan
4. Check Plex logs for import errors

---

## Security Considerations

### Authentication

Always enable authentication in Radarr:
- Settings → General → Security → Authentication
- Forms (Login Page) recommended
- Set strong username/password

### API Key Security

- Keep API key secret
- Only share with trusted services (Overseerr, Homarr)
- Regenerate if compromised: Settings → General → Security

### Network Access

- Radarr accessible only on local network (172.16.10.216)
- Do not expose to internet without VPN
- Use authentication even on local network

---

## Advanced Configuration

### Custom Scripts

Radarr can run custom scripts on events:

Settings → Connect → Custom Script

**Events:**
- On Grab (when download starts)
- On Import (when movie added to library)
- On Upgrade (when better quality downloaded)
- On Rename (when files renamed)
- On Health Issue
- On Application Update

**Use Cases:**
- Send notifications
- Update external databases
- Trigger Plex refreshes
- Sync to backup location

### Quality Definitions

Fine-tune quality sizes:

Settings → Quality

Adjust size limits for each quality:
- Set minimum/maximum file sizes
- Prevents downloads that are too small (poor quality) or too large (unnecessary)

### Lists

Automatically add movies from lists:

Settings → Lists → Add List

**Sources:**
- IMDb lists
- Trakt lists
- TMDb lists
- Custom RSS feeds

Radarr will automatically add and download new movies from these lists.

---

## Quick Reference Commands

### Access Radarr
```
http://172.16.10.216:7878
```

### Start/Stop/Restart
```bash
ssh homarr@172.16.10.216
cd ~/Homarr

# Start
docker compose up -d radarr

# Stop
docker compose stop radarr

# Restart
docker compose restart radarr

# View logs
docker compose logs -f radarr
```

### Update
```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose pull radarr
docker compose up -d radarr
```

---

## Next Steps

After Radarr is running:

1. ☐ Deploy Radarr container
2. ☐ Complete initial setup wizard
3. ☐ Configure root folder (/movies or KNHOST mount)
4. ☐ Add download client (qBittorrent recommended)
5. ☐ Add indexers (Jackett recommended)
6. ☐ Configure quality profiles
7. ☐ Connect Overseerr to Radarr
8. ☐ Test with manual movie add
9. ☐ Test full pipeline with Overseerr request
10. ☐ Add Radarr to Homarr dashboard
11. ☐ Consider adding Sonarr for TV automation

---

## Resources

- **Radarr Docs:** https://wiki.servarr.com/radarr
- **Docker Image:** https://github.com/linuxserver/docker-radarr
- **Your Setup:**
  - VM: 172.16.10.216
  - Port: 7878
  - Movies: D:\Movies (KNHOST) or ~/Homarr/media/movies (VM)

---

**Created:** February 13, 2026  
**Radarr URL:** http://172.16.10.216:7878  
**Status:** Ready to deploy  
**Part of:** Full Plex Automation Stack
