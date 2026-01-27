# Homarr Dashboard Project - Complete State Documentation

**Project Created:** January 27, 2026  
**Status:** ✅ Successfully Deployed and Running  
**Dashboard URL:** http://172.16.10.216:7575

---

## Project Overview

This project sets up a Homarr dashboard to monitor and manage home automation services and infrastructure on Windows Server 2022 using a Hyper-V Ubuntu VM.

## Infrastructure Setup

### Windows Server Environment
- **Server:** Windows Server 2022 Datacenter (Build 20348.4529)
- **Host:** KNHOST
- **Resources:** 32 CPUs, 127.9GB RAM
- **Docker:** 24.0.7 (Windows containers mode)

### Hyper-V Ubuntu VM
- **VM Name:** Homarr-Ubuntu
- **OS:** Ubuntu 24.04.3 LTS Server
- **Memory:** 4GB
- **Processors:** 2 CPUs
- **Disk:** 40GB VHDX
- **Network:** LAN-Local-External switch
- **IP Address:** 172.16.10.216
- **VM Location:** E:\HyperV\VMs\Homarr-Ubuntu\
- **ISO Used:** E:\ISO\ubuntu-24.04.3-live-server-amd64.iso
- **Auto-start:** Enabled

### Docker Configuration
- **Docker Version:** Installed via get.docker.com script
- **Docker Compose:** Plugin version installed
- **Container Name:** homarr
- **Image:** ghcr.io/ajnart/homarr:latest
- **Port:** 7575
- **Restart Policy:** unless-stopped

---

## Project Structure

```
D:\Projects\Homarr\
├── .git/                          # Git repository
├── .gitignore                     # Git ignore rules (includes .env, homarr/data/, etc.)
├── docker-compose.yml             # Docker Compose configuration
├── .env.example                   # Environment variable template
├── .env                          # Actual environment variables (gitignored)
├── homarr/                       # Homarr data directories
│   ├── configs/                  # Configuration files (gitignored)
│   ├── icons/                    # Custom icons (gitignored except .gitkeep)
│   │   └── .gitkeep             # Keeps directory in git
│   └── data/                     # Application data (gitignored)
├── setup-docker.sh               # Docker installation script for VM
├── finish-setup.sh               # Docker setup completion script
├── README.md                     # Main project documentation
├── SERVICES.md                   # Services to track documentation
├── HYPERV_SETUP.md              # Hyper-V VM setup guide (recommended)
├── WINDOWS_SERVER_SETUP.md      # Alternative setup methods
└── PROJECT_STATE.md             # This file

VM Location: /home/homarr/Homarr/ (copy of this directory via SCP)
```

---

## What We Accomplished

### Phase 1: Project Planning & Setup
1. ✅ Created project directory at D:\Projects\Homarr
2. ✅ Initialized git repository
3. ✅ Created Docker Compose configuration for Homarr
4. ✅ Set up directory structure for configs, icons, and data
5. ✅ Created comprehensive documentation (README, SERVICES)
6. ✅ Configured .gitignore for security (excludes .env, runtime data)

### Phase 2: Windows Server Analysis
1. ✅ Identified Docker running in Windows container mode
2. ✅ Determined Linux containers required for Homarr
3. ✅ Evaluated deployment options (Docker Desktop, WSL2, Hyper-V VM)
4. ✅ Recommended Hyper-V Linux VM approach for Windows Server 2022

### Phase 3: Hyper-V VM Creation
1. ✅ Created comprehensive Hyper-V setup documentation
2. ✅ Created Ubuntu Server VM via PowerShell automation
   - VM name: Homarr-Ubuntu
   - Resources: 4GB RAM, 2 CPUs, 40GB disk
   - Network: Connected to LAN-Local-External switch
   - Secure Boot: Disabled for Linux compatibility
   - Auto-start: Enabled
3. ✅ Configured VM with Ubuntu 24.04.3 LTS installation
4. ✅ Set up SSH access (OpenSSH server installed)
5. ✅ Obtained VM IP: 172.16.10.216

### Phase 4: Docker & Homarr Deployment
1. ✅ Created automated Docker installation scripts
2. ✅ Transferred Homarr project files to VM via SCP
3. ✅ Installed Docker and Docker Compose in VM
4. ✅ Configured docker group membership for homarr user
5. ✅ Deployed Homarr container successfully
6. ✅ Verified accessibility from Windows Server
7. ✅ Created user account in Homarr dashboard

### Phase 5: Configuration & Documentation
1. ✅ Created .env.example template for environment variables
2. ✅ Updated docker-compose.yml to use .env file
3. ✅ Documented all setup procedures
4. ✅ Created troubleshooting guides
5. ✅ Committed all changes to git (3 commits total)

---

## Services to Monitor

The Homarr dashboard is set up to monitor and provide quick access to:

1. **UniFi Dream Machine Pro**
   - Network Management
   - UniFi Protect (Camera/Security)

2. **Plex Media Server**
   - Media streaming

3. **Game Servers**
   - Various gaming infrastructure

4. **Docker Containers**
   - Container management

5. **File Sharing Servers**
   - Network storage

---

## Key Commands & Access

### Accessing Homarr Dashboard
- **URL:** http://172.16.10.216:7575
- Access from any machine on the network

### SSH into VM
```powershell
ssh homarr@172.16.10.216
```

### Managing Homarr Container (from within VM)
```bash
cd ~/Homarr

# View logs
docker compose logs -f

# Restart container
docker compose restart

# Stop container
docker compose down

# Start container
docker compose up -d

# Update Homarr
docker compose pull
docker compose up -d
```

### Managing VM (from Windows Server)
```powershell
# Check VM status
Get-VM -Name "Homarr-Ubuntu"

# Start VM
Start-VM -Name "Homarr-Ubuntu"

# Stop VM
Stop-VM -Name "Homarr-Ubuntu"

# Connect to VM console
vmconnect.exe localhost Homarr-Ubuntu

# Get VM network info
Get-VMNetworkAdapter -VMName "Homarr-Ubuntu"
```

---

## Git Repository Status

### Commits
1. **fc54722** - Initial commit: Homarr dashboard setup
2. **853930c** - Add Windows Server 2022 and Hyper-V setup guides
3. **1b9da13** - Add environment configuration and setup scripts

### Current Branch
- **main** (local only, not yet pushed to remote)

### Files Tracked
- Docker configuration files
- Documentation (README, guides, service lists)
- Setup scripts
- .env.example template
- .gitkeep for directory structure

### Files Ignored (.gitignore)
- .env (contains credentials)
- homarr/data/ (runtime data)
- homarr/configs/ (user configurations)
- homarr/icons/* (custom uploaded icons)
- Backup files (*.backup, *.bak)
- OS specific files (.DS_Store, Thumbs.db)
- Editor directories (.vscode, .idea)

---

## Backup Strategy

### Current State (Pre-GitHub Push)
⚠️ **All data currently exists only on:**
- Windows Server: D:\Projects\Homarr (git repository)
- Ubuntu VM: /home/homarr/Homarr (working copy)
- VM disk: E:\HyperV\VMs\Homarr-Ubuntu\Homarr-Ubuntu.vhdx

### Recommended Backup Actions

1. **Push to GitHub** (PRIORITY - protects against HDD failure)
   ```powershell
   # Create GitHub repository, then:
   git remote add origin https://github.com/<username>/Homarr.git
   git push -u origin main
   ```

2. **VM Snapshots**
   ```powershell
   Checkpoint-VM -Name "Homarr-Ubuntu" -SnapshotName "Homarr-Working-$(Get-Date -Format 'yyyyMMdd')"
   ```

3. **Homarr Configuration Backup** (from VM)
   ```bash
   cd ~/Homarr
   tar -czf homarr-backup-$(date +%Y%m%d).tar.gz homarr/
   scp homarr-backup-*.tar.gz Administrator@<WINDOWS-SERVER-IP>:D:/Backups/
   ```

---

## Known Issues & Solutions

### Issue: Windows Line Endings in Scripts
- **Problem:** setup-docker.sh had CRLF line endings causing errors in Linux
- **Solution:** Created finish-setup.sh with proper LF endings
- **Prevention:** Use `git config core.autocrlf false` or create scripts in Linux

### Issue: Docker Permission Denied
- **Problem:** User not in docker group after installation
- **Solution:** Added user to docker group, required logout/login for changes
- **Command:** `sudo usermod -aG docker $USER`

### Issue: VM IP Not Reported to Hyper-V
- **Problem:** Hyper-V integration services didn't immediately report IP
- **Solution:** Check IP directly in VM with `ip addr show` or `hostname -I`

---

## Next Steps & Future Enhancements

### Immediate (Not Yet Done)
- [ ] Push repository to GitHub for backup
- [ ] Create GitHub repository (public or private)
- [ ] Configure GitHub remote
- [ ] Push all commits

### Configuration (In Progress)
- [x] Access Homarr dashboard
- [x] Create user account
- [ ] Add all services (UniFi, Plex, game servers, etc.)
- [ ] Configure widgets and layout
- [ ] Set up service monitoring
- [ ] Configure API integrations (Plex token, UniFi credentials, etc.)

### Enhancements (Future)
- [ ] Set up automated Homarr configuration backups
- [ ] Configure static IP for VM (currently DHCP: 172.16.10.216)
- [ ] Set up reverse proxy (nginx/traefik) if adding more services
- [ ] Add custom themes to Homarr
- [ ] Configure automated VM backups
- [ ] Set up monitoring alerts
- [ ] Document API integration procedures

---

## Important Notes

### Security Considerations
- .env file contains credentials - never commit to git
- homarr/configs may contain API tokens - gitignored
- SSH password authentication used (consider SSH keys for automation)
- Homarr accessible on local network only (172.16.10.216:7575)

### Maintenance Schedule
- **Weekly:** Review Homarr dashboard, check service status
- **Monthly:** Update Homarr container, backup configurations
- **Quarterly:** Review and update documentation, check VM disk space
- **As Needed:** Add new services, update credentials

### Dependencies
- Hyper-V must be running for Homarr to be accessible
- VM must be running (configured for auto-start)
- Docker service in VM must be running (enabled at boot)
- Network connectivity required (LAN-Local-External switch)

---

## Technical Details

### Network Configuration
- **VM Network Adapter:** LAN-Local-External switch
- **IP Assignment:** DHCP (172.16.10.216)
- **MAC Address:** 00155D0ABE0E
- **Firewall:** Port 7575 open on VM

### Docker Container Details
```yaml
Container: homarr
Image: ghcr.io/ajnart/homarr:latest
Ports: 7575:7575
Volumes:
  - ./homarr/configs:/app/data/configs
  - ./homarr/icons:/app/public/icons
  - ./homarr/data:/data
Environment:
  - TZ=${TZ:-America/New_York}
Restart: unless-stopped
```

### VM Specifications
```
Name: Homarr-Ubuntu
Generation: 2
State: Running
CPUs: 2
Memory: 4GB (4294967296 bytes)
Disk: 40GB VHDX (E:\HyperV\VMs\Homarr-Ubuntu\Homarr-Ubuntu.vhdx)
Network: LAN-Local-External
Secure Boot: Off
Auto-Start: Enabled
```

---

## Contact & Support

### Project Resources
- **Dashboard:** http://172.16.10.216:7575
- **VM Console:** `vmconnect.exe localhost Homarr-Ubuntu`
- **SSH Access:** `ssh homarr@172.16.10.216`

### External Resources
- **Homarr Documentation:** https://homarr.dev
- **Homarr GitHub:** https://github.com/ajnart/homarr
- **Docker Documentation:** https://docs.docker.com
- **Ubuntu Server Guide:** https://ubuntu.com/server/docs

---

## Success Metrics

✅ **Project Goals Achieved:**
1. Homarr dashboard successfully deployed and accessible
2. Running on dedicated Ubuntu VM in Hyper-V
3. All documentation created and organized
4. Git repository initialized with full history
5. User account created and dashboard configured
6. VM configured for automatic startup
7. Backup procedures documented

📊 **Current Status:**
- **Deployment:** 100% Complete
- **Documentation:** 100% Complete
- **Configuration:** 25% Complete (dashboard accessible, services not yet added)
- **Backup:** 0% Complete (needs GitHub push)

---

**Last Updated:** January 27, 2026 at 22:34 UTC  
**Document Version:** 1.0  
**Project Status:** ✅ Active and Running
