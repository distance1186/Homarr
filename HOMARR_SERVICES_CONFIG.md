# Homarr Services Configuration Guide

This guide will help you add all your services to the Homarr dashboard at http://172.16.10.216:7575

---

## Service List & Configuration

### 1. Plex Media Server

**Access URL:** http://KNHOST:32400/web
- Or use the server's actual IP: http://172.16.10.x:32400/web

**Configuration in Homarr:**
1. Click "Add Service" or "+"
2. **Name:** Plex Media Server
3. **URL:** `http://KNHOST:32400/web` (replace KNHOST with actual IP if needed)
4. **Icon:** Search "Plex" (Homarr has built-in icon)
5. **Category:** Media

**Enhanced Integration (Optional):**
- **Plex Widget:** Shows recently added media, currently playing
- **Requires:** Plex authentication token
- **To get token:**
  1. Open Plex in browser
  2. Play any media
  3. Click the info icon (ⓘ)
  4. View XML
  5. Look for `X-Plex-Token` in the URL

**Media Library Info:**
- Movies: D:\Movies (includes 15 anime movies)
- TV Shows: D:\TV (includes 9 anime TV shows)
- Automated sorting: D:\To be sorted

---

### 2. UniFi Dream Machine Pro

**Access URL:** https://<UDM-IP> (typically https://192.168.1.1 or your gateway IP)

**Configuration in Homarr:**
1. **Name:** UniFi Dream Machine Pro
2. **URL:** `https://<YOUR-UDM-IP>`
3. **Icon:** Search "UniFi"
4. **Category:** Network & Security

**Features to Monitor:**
- Network management
- UniFi Protect (cameras/security)
- IPS/IDS alerts
- Connected devices

**Security Notes:**
- KNHOST is currently the most targeted machine in IPS logs
- Review IPS logs regularly via UniFi interface
- Consider enabling IPS Prevention mode (currently in Detection only)

**API Integration (Optional):**
- UniFi API files located at: C:\Warp\UniFi-Portable
- Can be used for custom integrations if needed

---

### 3. MCP Gateway (IIS Gateway)

**Access URL:** http://KNHOST or https://KNHOST

**Configuration in Homarr:**
1. **Name:** MCP Gateway
2. **URL:** `http://KNHOST` or use server IP
3. **Icon:** Search "IIS" or "Server"
4. **Category:** Infrastructure

**Backend Services (Ports 3001-3004):**
- MCP-Files Service
- MCP-Database Service  
- MCP-API Service

**Gateway Ports:**
- HTTP: 80
- HTTPS: 443

**Project Location:** C:\Warp\mcp-gateway

---

### 4. Docker & Containers

**Docker on Homarr VM:**

**Configuration in Homarr:**
1. **Name:** Docker (Homarr VM)
2. **URL:** `http://172.16.10.216` (or specific container ports)
3. **Icon:** Search "Docker"
4. **Category:** Infrastructure

**Running Containers:**
- Homarr dashboard itself (port 7575)
- Local LLM (when configured)
- Future containers as needed

**Docker Widget (Advanced):**
- Homarr can display Docker container status
- Requires Docker socket access
- Shows running/stopped containers, resource usage

To enable Docker monitoring in Homarr:
1. SSH to VM: `ssh homarr@172.16.10.216`
2. Ensure docker socket is accessible
3. In Homarr, add Docker widget pointing to VM

---

### 5. Windows Server (KNHOST)

**Access URL:** http://KNHOST (RDP or management interfaces)

**Configuration in Homarr:**
1. **Name:** KNHOST (Windows Server)
2. **URL:** `rdp://KNHOST` or management URL
3. **Icon:** Search "Windows" or "Server"
4. **Category:** Infrastructure

**Server Stats:**
- 32 CPUs
- 127.9GB RAM
- Windows Server 2022 Datacenter (Build 20348.4529)
- Docker 24.0.7 (Windows containers mode)

**Services Running:**
- Plex Update Service
- IIS (MCP Gateway)
- Hyper-V (hosting Homarr VM)

---

### 6. File Shares / Network Storage

**Access URLs:**
- Movies: `\\KNHOST\D$\Movies` or file browser URL
- TV Shows: `\\KNHOST\D$\TV`
- To be sorted: `\\KNHOST\D$\To be sorted`

**Configuration in Homarr:**
1. **Name:** Media Storage
2. **URL:** `file://KNHOST/D$/Movies` or web file manager if available
3. **Icon:** Search "Folder" or "Storage"
4. **Category:** Storage

**Automated Sorting:**
- Script: D:\Projects\plex\Sort-NewDownloads.ps1
- Runs: Manual or scheduled task at 3am
- Function: Auto-sorts new media from "To be sorted" to Movies/TV

---

## Dashboard Organization Recommendations

### Layout Option 1: By Category

**Network & Security**
- UniFi Dream Machine Pro

**Media Services**
- Plex Media Server
- Media Storage

**Infrastructure**
- KNHOST (Windows Server)
- MCP Gateway
- Docker (Homarr VM)

---

### Layout Option 2: By Priority

**Primary Services** (Top row)
- Plex Media Server
- UniFi Dream Machine Pro
- Docker

**Support Services** (Second row)
- KNHOST Server
- MCP Gateway
- Media Storage

---

## Widgets to Add

### System Monitoring
1. **Calendar Widget** - Track maintenance schedules
2. **Weather Widget** - Optional
3. **RSS Feed** - Tech news or monitoring alerts
4. **Date & Time** - Quick reference

### Service-Specific
1. **Plex Widget** - Recently added media, now playing
2. **Docker Widget** - Container status (on Homarr VM)
3. **Network Speed** - Monitor bandwidth
4. **Server Stats** - CPU/RAM usage if available

---

## Step-by-Step Setup Process

### Phase 1: Add Basic Services (5-10 minutes)

1. Open Homarr: http://172.16.10.216:7575
2. Log in with your account
3. Click "Edit Mode" or Settings icon
4. Add services one by one using "Add Service" button
5. For each service:
   - Enter name and URL
   - Select appropriate icon
   - Assign to category
   - Save

### Phase 2: Configure Widgets (10-15 minutes)

1. Stay in Edit Mode
2. Click "Add Widget"
3. Choose widget type (Plex, Docker, Calendar, etc.)
4. Configure widget settings
5. Drag to position on dashboard
6. Save layout

### Phase 3: Test & Refine (5 minutes)

1. Exit Edit Mode
2. Test each service link
3. Verify widgets are updating
4. Adjust layout as needed

---

## API Tokens & Credentials Needed

### For Enhanced Integrations:

1. **Plex Token** (for media widgets)
   - Get from Plex web interface as described above
   - Add to Homarr Plex widget configuration

2. **UniFi API Key** (for network monitoring)
   - Located at: C:\Warp\UniFi-Portable
   - Check UniFi-Monitor-Config.ps1 for API details

3. **Docker Socket** (for container monitoring)
   - Already accessible on Homarr VM
   - Path: unix:///var/run/docker.sock

---

## Security Considerations

### Internal Network Only
- Homarr is accessible only on local network (172.16.10.216)
- No external exposure (good for security)
- Access from any device on your network

### Credentials Management
- Store API tokens in Homarr's secure storage
- Don't share dashboard publicly
- Regular password rotation recommended

### KNHOST Security Notes
- Currently most targeted machine in network
- Monitor UniFi IPS alerts regularly
- Consider enabling IPS Prevention mode
- Review C:\Warp\UniFi-Portable\QUICKSTART.txt for hardening steps

---

## Troubleshooting

### Service Not Accessible
1. Verify service is running
2. Check firewall rules
3. Confirm correct IP/port
4. Test from Windows Server first, then from other devices

### Widget Not Updating
1. Verify API token is correct
2. Check Homarr logs: `ssh homarr@172.16.10.216 "cd ~/Homarr && docker compose logs"`
3. Refresh dashboard cache
4. Re-add widget if needed

### Dashboard Slow
1. Reduce number of active widgets
2. Increase refresh intervals
3. Check Homarr VM resources (currently 4GB RAM, may need more)

---

## Future Enhancements

### Additional Services to Consider

1. **Local LLM** (when configured in Docker)
   - Add as service once deployed
   - Useful for AI-assisted tasks

2. **Game Servers** (when identified)
   - Add each game server with specific ports
   - Monitor server status

3. **Monitoring Dashboards**
   - Grafana (if deployed)
   - Prometheus (if deployed)
   - System monitoring tools

4. **Backup Services**
   - VM backup status
   - Configuration backup monitor

### Advanced Configurations

1. **Custom CSS Themes**
   - Personalize dashboard appearance
   - Match your preferences

2. **Mobile Access**
   - Access from phone/tablet
   - Responsive layout already included

3. **Notifications**
   - Service down alerts
   - System health notifications
   - Integration with Discord/Slack/email

---

## Quick Reference Commands

### Access Homarr Dashboard
```
http://172.16.10.216:7575
```

### SSH to Homarr VM
```powershell
ssh homarr@172.16.10.216
```

### View Homarr Logs
```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose logs -f
```

### Restart Homarr
```bash
ssh homarr@172.16.10.216
cd ~/Homarr
docker compose restart
```

### Check VM Status
```powershell
Get-VM -Name "Homarr-Ubuntu"
```

---

## Next Steps

1. ☐ Add Plex Media Server to dashboard
2. ☐ Add UniFi Dream Machine Pro
3. ☐ Add MCP Gateway
4. ☐ Add Docker monitoring
5. ☐ Configure Plex widget (with token)
6. ☐ Organize dashboard layout
7. ☐ Test all service links
8. ☐ Set up any additional widgets
9. ☐ Take screenshot/backup of configuration

---

**Created:** January 28, 2026  
**Dashboard URL:** http://172.16.10.216:7575  
**For:** KNHOST Windows Server 2022
