# Services

Running services tracked in Homarr at `http://<VM-IP>:7575`.

See `HOW_TO_ADD_SERVICE.md` for the workflow to add new services.

## Docker Services (auto-visible in Docker widget)

| Service   | Port | Image                                    |
|-----------|------|------------------------------------------|
| Homarr    | 7575 | ghcr.io/homarr-labs/homarr:latest        |
| Radarr    | 7878 | lscr.io/linuxserver/radarr:latest        |
| Overseerr | 5055 | lscr.io/linuxserver/overseerr:latest     |

## Non-Docker Services (add manually in Homarr UI once)

| Service                 | URL                        | Category          |
|-------------------------|----------------------------|-------------------|
| Plex Media Server       | http://<SERVER-HOST>:32400        | Media             |
| UniFi Dream Machine Pro | https://<UDM-IP>           | Network & Security|
| <SERVER-HOST> Windows Server   | rdp://<SERVER-HOST>               | Infrastructure    |
