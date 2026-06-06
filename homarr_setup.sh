#!/bin/bash
ENV_FILE=~/Homarr/.env
BASE=http://localhost:7575
COOKIE_JAR=/tmp/homarr_cookies.txt

USER=$(grep "^homarUsername=" "$ENV_FILE" | cut -d= -f2- | tr -d "\r")
PASS=$(grep "^homarPassword" "$ENV_FILE" | sed 's/^[^:=]*[=:]//' | tr -d "\r" | xargs)

echo ">>> Logging in as: $USER"

rm -f "$COOKIE_JAR"
CSRF=$(curl -sc "$COOKIE_JAR" -s "$BASE/api/auth/csrf" | grep -o '"csrfToken":"[^"]*"' | cut -d'"' -f4)
echo ">>> CSRF: ${CSRF:0:10}..."

curl -sb "$COOKIE_JAR" -sc "$COOKIE_JAR" -s -o /dev/null -L \
  -X POST "$BASE/api/auth/callback/credentials" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "name=$USER" \
  --data-urlencode "password=$PASS" \
  --data-urlencode "csrfToken=$CSRF" \
  --data-urlencode "callbackUrl=$BASE" \
  --data-urlencode "json=true"

SESSION=$(grep "authjs.session-token" "$COOKIE_JAR" | awk '{print $NF}' | tr -d "\r")
echo ">>> Session token length: ${#SESSION}"

if [ -z "$SESSION" ]; then
  echo "ERROR: Login failed"
  exit 1
fi

create_app() {
  local NAME="$1"
  local HREF="$2"
  local DESC="$3"
  local ICON="$4"
  echo ""
  echo ">>> Creating app: $NAME"
  curl -s -w "\nHTTP:%{http_code}" \
    -X POST "$BASE/api/apps" \
    -H "Content-Type: application/json" \
    -H "Cookie: authjs.session-token=$SESSION" \
    -d "{\"name\":\"$NAME\",\"href\":\"$HREF\",\"description\":\"$DESC\",\"iconUrl\":\"$ICON\",\"pingUrl\":null}"
  echo ""
}

CDN="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg"

create_app "Radarr"    "http://<VM-IP>:7878" "Movie Management"   "$CDN/radarr.svg"
create_app "Overseerr" "http://<VM-IP>:5055" "Media Requests"     "$CDN/overseerr.svg"
create_app "Plex"      "http://<SERVER-HOST>:32400/web"   "Media Server"       "$CDN/plex.svg"
create_app "UniFi"     "https://192.168.1.1"       "Network Management" "$CDN/unifi.svg"

echo ""
echo ">>> All done! Open http://<VM-IP>:7575 and add the apps to a board."
