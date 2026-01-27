# Homarr Dashboard

A centralized dashboard for managing and monitoring home automation services and infrastructure.

## Overview

This Homarr dashboard provides a unified interface to monitor and access all home services including:

- **UniFi Dream Machine Pro** - Network management and UniFi Protect
- **Plex Media Server** - Media streaming
- **Game Servers** - Gaming infrastructure
- **Docker Containers** - Container management
- **File Sharing Servers** - Network storage

## Prerequisites

- Docker Desktop installed and running (includes Docker Compose)
- Docker Compose v2 plugin or standalone docker-compose
- Access to your local network services

**Important for Windows Server 2022 Users:** Your system is currently running Windows containers. Homarr requires Linux containers. The recommended approach is to run Homarr in a Linux VM using Hyper-V. See [HYPERV_SETUP.md](HYPERV_SETUP.md) for step-by-step instructions, or [WINDOWS_SERVER_SETUP.md](WINDOWS_SERVER_SETUP.md) for alternative options.

**Note:** On Windows, ensure Docker Desktop is running before executing docker commands.

## Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd Homarr
   ```

2. Update the timezone in `docker-compose.yml` if needed (default: America/New_York)

3. Start the Homarr dashboard:
   ```bash
   docker-compose up -d
   ```

4. Access the dashboard at: http://localhost:7575

## Configuration

### First Time Setup

1. Navigate to http://localhost:7575
2. Complete the initial setup wizard
3. Add your services using the "Add Service" button
4. Configure widgets for monitoring and quick access

### Adding Services

For each service you want to track:

1. Click the "+" button or "Add Service"
2. Enter the service name, URL, and icon
3. Configure monitoring options if supported
4. Save the configuration

### Service URLs

You'll need to know the IP addresses or hostnames of your services:
- UniFi Dream Machine Pro: typically `https://<udm-ip>`
- Plex: typically `http://<plex-ip>:32400`
- Other services: check their respective documentation

## Directory Structure

```
.
├── docker-compose.yml          # Docker Compose configuration
├── homarr/
│   ├── configs/               # Homarr configuration files
│   ├── icons/                 # Custom service icons
│   └── data/                  # Application data
├── SERVICES.md                # List of services to track
└── README.md                  # This file
```

## Management

### Start the dashboard
```bash
docker-compose up -d
```

### Stop the dashboard
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f homarr
```

### Update Homarr
```bash
docker-compose pull
docker-compose up -d
```

## Data Persistence

All configuration and data is stored in the `./homarr` directory. This directory is mounted as a volume in the container, ensuring your settings persist across container restarts and updates.

## Backup

To backup your Homarr configuration:
```bash
# Backup the homarr directory
tar -czf homarr-backup-$(date +%Y%m%d).tar.gz homarr/
```

## Troubleshooting

### Port 7575 already in use
Edit `docker-compose.yml` and change the port mapping:
```yaml
ports:
  - '8080:7575'  # Use port 8080 instead
```

### Container won't start
Check logs:
```bash
docker-compose logs homarr
```

### Reset configuration
Stop the container and remove the homarr/configs directory:
```bash
docker-compose down
rm -rf homarr/configs/*
docker-compose up -d
```

## Future Plans

- [ ] Configure GitHub remote repository
- [ ] Set up automated backups
- [ ] Add custom themes
- [ ] Integrate service-specific APIs for enhanced monitoring

## License

This project configuration is provided as-is for personal use.

## Support

For Homarr-specific issues, visit: https://github.com/ajnart/homarr
