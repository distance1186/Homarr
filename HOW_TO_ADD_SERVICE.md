# How to Add a New Service to Homarr

This document explains the workflow for registering a new service on the Homarr dashboard.

---

## Docker-based Services (Recommended)

For any service that runs as a Docker container on the same host as Homarr, follow these steps:

### Step 1 — Add it to docker-compose.yml

Add your new service to `docker-compose.yml`. Example:

```yaml
myservice:
  container_name: myservice
  image: someimage:latest
  restart: unless-stopped
  ports:
    - '8080:8080'
  volumes:
    - ./myservice/config:/config
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=${TZ:-America/New_York}
```

### Step 2 — Start the container

```bash
docker compose up -d myservice
```

### Step 3 — Add it to the Homarr dashboard

Homarr automatically detects all running containers via the Docker socket. To add the service as a proper app tile:

1. Open Homarr at `http://<VM-IP>:7575`
2. Go to **Tools → Docker** (or the Docker Containers widget on your board)
3. Find your new container in the list
4. Check the box next to it → click **Add to Homarr**
5. Fill in the public-facing URL for the service (e.g. `http://<VM-IP>:8080`)
6. Click **Add** — the tile appears on your board immediately

> All containers are visible in the Docker widget automatically the moment they start.
> The "Add to Homarr" step takes about 1 minute and only needs to be done once per service.

---

## Non-Docker Services

For services not running in Docker on this host (e.g. Plex on the Windows Server, UniFi, etc.):

1. Open Homarr → click **Edit** (pencil icon, top right)
2. Click **+ Add** → **App**
3. Fill in:
   - **Name**: Display name
   - **URL**: The service's address (e.g. `http://<SERVER-HOST>:32400`)
   - **Icon**: Search the built-in icon library
4. Click **Save**

These only need to be added once — they persist in Homarr's database.

---

## Setting Up Integrations (Optional but Recommended)

For supported services (Radarr, Overseerr, Plex, etc.), you can enable a live data integration:

1. Homarr → **Settings → Integrations → Add Integration**
2. Select the service type
3. Enter the internal URL and API key
4. Click **Test Connection** → **Save**

The integration enables live widgets (queue status, now playing, etc.) on your board.

| Service    | Default URL                        | Where to get API key                       |
|------------|------------------------------------|--------------------------------------------|
| Radarr     | `http://radarr:7878`               | Radarr → Settings → General → API Key     |
| Overseerr  | `http://overseerr:5055`            | Overseerr → Settings → General → API Key  |
| Plex       | `http://<SERVER-HOST>:32400`              | Plex → Account → Plex Token               |

---

## Current Services

| Service    | Port  | Type       | On Homarr board? |
|------------|-------|------------|------------------|
| Homarr     | 7575  | Docker     | — (it is the board) |
| Radarr     | 7878  | Docker     | Add via step 3 above |
| Overseerr  | 5055  | Docker     | Add via step 3 above |
| Plex       | 32400 | Non-Docker | Add manually     |
| UniFi      | 443   | Non-Docker | Add manually     |

---

## First-Time Setup (After Deploying to Linux)

Before starting Homarr for the first time on the Linux host:

```bash
# Generate the required encryption key
openssl rand -hex 32
# Paste the output into .env as: SECRET_ENCRYPTION_KEY=<output>

# Create the appdata directory
mkdir -p ./homarr/appdata

# Start the stack
docker compose up -d

# Open Homarr and create your admin account
# http://<VM-IP>:7575
```
