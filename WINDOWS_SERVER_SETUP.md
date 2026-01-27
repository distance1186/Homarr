# Windows Server 2022 Setup Guide

## Important: Linux Containers Required

Your Windows Server 2022 system is currently configured for **Windows containers**, but Homarr requires **Linux containers**. You have two options:

### Option 1: Install Docker Desktop (Recommended for Development)

Docker Desktop provides easy switching between Windows and Linux containers:

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop/
2. Install Docker Desktop
3. Right-click the Docker Desktop icon in system tray
4. Select "Switch to Linux containers..."
5. Wait for Docker to restart

**Note:** Docker Desktop requires Windows 10/11 or Windows Server 2019+ with Desktop Experience. On Server Core, use Option 2.

### Option 2: Use WSL2 with Docker (For Windows Server)

If you don't have Desktop Experience or prefer WSL2:

1. **Enable WSL2:**
   ```powershell
   wsl --install
   # Reboot if required
   wsl --set-default-version 2
   ```

2. **Install a Linux distribution:**
   ```powershell
   wsl --install -d Ubuntu
   ```

3. **Install Docker inside WSL2:**
   ```bash
   # Inside WSL2 Ubuntu shell
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

4. **Install Docker Compose in WSL2:**
   ```bash
   sudo apt-get update
   sudo apt-get install docker-compose-plugin
   ```

5. **Navigate to your project in WSL2:**
   ```bash
   cd /mnt/d/Projects/Homarr
   docker compose up -d
   ```

### Option 3: Use a Linux VM

Run Docker in a Linux VM using Hyper-V:

1. Create an Ubuntu/Debian VM in Hyper-V
2. Install Docker in the VM
3. Either:
   - Run Homarr in the VM and access via network
   - Mount the D:\Projects\Homarr directory to the VM

## Current System Information

- **Server:** Windows Server 2022 Datacenter (Build 20348.4529)
- **Docker Version:** 24.0.7
- **Current Mode:** Windows Containers (native)
- **Storage Driver:** windowsfilter

## Verification

After switching to Linux containers, verify with:

```powershell
docker info | Select-String "OSType"
```

You should see: `OSType: linux`

## Starting Homarr

Once Linux containers are enabled:

```powershell
# Using Docker Compose v2 (plugin style)
docker compose up -d

# Or if you have standalone docker-compose
docker-compose up -d
```

Access at: http://localhost:7575

## Troubleshooting

### "image operating system 'linux' cannot be used on this platform"

This means Docker is still in Windows container mode. Switch to Linux containers first.

### WSL2 Not Available

Ensure virtualization is enabled in BIOS and Windows features are installed:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
```

Reboot after enabling these features.
