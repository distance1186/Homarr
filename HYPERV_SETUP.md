# Hyper-V Linux VM Setup for Homarr

This guide will help you create a Linux VM in Hyper-V to run your Homarr dashboard.

## Quick Setup Overview

1. Create Ubuntu Server VM in Hyper-V
2. Install Docker in the VM
3. Copy/mount the Homarr project files
4. Start Homarr and access via network

## Step 1: Create Ubuntu Server VM

### Download Ubuntu Server ISO

Download Ubuntu Server 22.04 LTS (or latest):
- https://ubuntu.com/download/server
- Save to a location accessible by Hyper-V (e.g., `C:\ISOs\`)

### Create VM in Hyper-V

```powershell
# Create a new VM
$VMName = "Homarr-Ubuntu"
$VMPath = "C:\HyperV\VMs"
$ISOPath = "C:\ISOs\ubuntu-22.04-live-server-amd64.iso"
$VHDPath = "$VMPath\$VMName\$VMName.vhdx"

# Create VM
New-VM -Name $VMName -MemoryStartupBytes 4GB -Generation 2 -NewVHDPath $VHDPath -NewVHDSizeBytes 40GB -Path $VMPath

# Configure VM
Set-VM -Name $VMName -ProcessorCount 2 -AutomaticStartAction Start -AutomaticStopAction ShutDown

# Add DVD drive with ISO
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# Get network switch (use your existing switch or create one)
$Switch = Get-VMSwitch | Select-Object -First 1
Connect-VMNetworkAdapter -VMName $VMName -SwitchName $Switch.Name

# Disable Secure Boot (for Linux)
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Start VM
Start-VM -Name $VMName
```

### Or Create Manually via Hyper-V Manager:

1. Open Hyper-V Manager
2. Right-click your server → New → Virtual Machine
3. Configuration:
   - **Name:** Homarr-Ubuntu
   - **Generation:** 2
   - **Memory:** 4096 MB (4GB)
   - **Network:** Connect to your existing virtual switch
   - **Hard Disk:** Create new, 40 GB
   - **Installation:** Specify Ubuntu Server ISO
4. Before starting, go to Settings:
   - Security → Disable Secure Boot
   - Processor → Set to 2 virtual processors

## Step 2: Install Ubuntu Server

1. Start the VM and connect via Hyper-V Manager console
2. Follow Ubuntu installation wizard:
   - Language: English
   - Keyboard: Your layout
   - Network: Use DHCP (note the IP address assigned)
   - Storage: Use entire disk
   - Profile setup:
     - Name: homarr
     - Server name: homarr-vm
     - Username: homarr
     - Password: [your choice]
   - SSH: **Install OpenSSH server** (check this option!)
   - Featured server snaps: Skip (we'll install Docker manually)
3. Complete installation and reboot

## Step 3: Configure Ubuntu and Install Docker

### Connect via SSH (Recommended)

From your Windows Server PowerShell:
```powershell
ssh homarr@<VM-IP-ADDRESS>
```

### Install Docker

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt-get install docker-compose-plugin -y

# Log out and back in for group changes to take effect
exit
```

SSH back in:
```powershell
ssh homarr@<VM-IP-ADDRESS>
```

### Verify Docker Installation

```bash
docker --version
docker compose version
```

## Step 4: Transfer Homarr Project to VM

### Option A: Use Git (Recommended if pushing to GitHub)

In the VM:
```bash
cd ~
git clone <your-github-url> Homarr
cd Homarr
```

### Option B: Use SCP to Copy Files

From Windows PowerShell:
```powershell
scp -r D:\Projects\Homarr homarr@<VM-IP-ADDRESS>:~/
```

### Option C: Create Network Share (Easiest)

**On Windows Server:**
```powershell
# Create SMB share
New-SmbShare -Name "Homarr" -Path "D:\Projects\Homarr" -FullAccess "Everyone"
```

**In Linux VM:**
```bash
# Install CIFS utilities
sudo apt install cifs-utils -y

# Create mount point
sudo mkdir -p /mnt/homarr

# Mount the share (replace <WINDOWS-SERVER-IP>)
sudo mount -t cifs //<WINDOWS-SERVER-IP>/Homarr /mnt/homarr -o username=Administrator,uid=$(id -u),gid=$(id -g)

# Or copy to local directory
cp -r /mnt/homarr ~/Homarr
cd ~/Homarr
```

## Step 5: Start Homarr

```bash
cd ~/Homarr  # or /mnt/homarr if using network share

# Start Homarr
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

## Step 6: Access Homarr Dashboard

From any machine on your network (including the Windows Server):
```
http://<VM-IP-ADDRESS>:7575
```

## VM Management Commands

### From Windows PowerShell:

```powershell
# Stop VM
Stop-VM -Name "Homarr-Ubuntu"

# Start VM
Start-VM -Name "Homarr-Ubuntu"

# Get VM status
Get-VM -Name "Homarr-Ubuntu"

# Connect to VM console
vmconnect.exe localhost "Homarr-Ubuntu"
```

### Inside the VM:

```bash
# Stop Homarr
docker compose down

# Start Homarr
docker compose up -d

# Restart Homarr
docker compose restart

# View logs
docker compose logs -f homarr

# Update Homarr
docker compose pull
docker compose up -d
```

## Networking Tips

### Find VM IP Address

In the VM:
```bash
ip addr show
# or
hostname -I
```

### Static IP (Optional but Recommended)

Edit netplan config:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Example configuration:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24  # Change to your network
      gateway4: 192.168.1.1  # Your router/gateway
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Apply changes:
```bash
sudo netplan apply
```

## Firewall Configuration

If you have a firewall on the VM:
```bash
# Allow port 7575
sudo ufw allow 7575/tcp
sudo ufw enable
```

On Windows Server, ensure the VM's IP can be reached from your network.

## Auto-Start Configuration

### Make Homarr Start on Boot

```bash
cd ~/Homarr

# Homarr is already configured with restart: unless-stopped
# It will automatically start when Docker starts

# Enable Docker to start on boot (should already be enabled)
sudo systemctl enable docker
```

### Make VM Start Automatically

From Windows PowerShell:
```powershell
Set-VM -Name "Homarr-Ubuntu" -AutomaticStartAction Start
```

## Backup Strategy

### Backup Homarr Configuration

```bash
# From inside the VM
cd ~/Homarr
tar -czf homarr-backup-$(date +%Y%m%d).tar.gz homarr/

# Copy backup to Windows Server
scp homarr-backup-*.tar.gz Administrator@<WINDOWS-SERVER-IP>:D:/Backups/
```

### VM Checkpoint/Snapshot

From Windows PowerShell:
```powershell
Checkpoint-VM -Name "Homarr-Ubuntu" -SnapshotName "Homarr-Working-$(Get-Date -Format 'yyyyMMdd')"
```

## Troubleshooting

### Can't connect via SSH
- Check VM IP: `ip addr show`
- Verify SSH is running: `sudo systemctl status ssh`
- Check Windows firewall isn't blocking SSH

### Can't access Homarr from Windows
- Verify container is running: `docker compose ps`
- Check VM IP is correct
- Test from VM itself: `curl http://localhost:7575`
- Check Hyper-V virtual switch allows VM-to-host communication

### Performance Issues
- Increase VM memory: `Set-VM -Name "Homarr-Ubuntu" -MemoryStartupBytes 8GB`
- Add more CPU cores: `Set-VM -Name "Homarr-Ubuntu" -ProcessorCount 4`

## Next Steps

1. Configure your services in Homarr dashboard
2. Set up automated backups
3. Consider setting up a reverse proxy (nginx/traefik) if adding more services
4. Push your Homarr configuration to GitHub for version control
