#!/usr/bin/env bash
# Call the notes API on server8 through an SSH tunnel and check a known tone.
# Same host variables as scripts/cd-deploy-api.sh. Port 8095 is not public.
set -euo pipefail

: "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}"
: "${DEPLOY_HOST:?DEPLOY_HOST is required}"
: "${DEPLOY_USER:?DEPLOY_USER is required}"
: "${DEPLOY_PORT:?DEPLOY_PORT is required}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY="$(mktemp)"
trap 'rm -f "$KEY"' EXIT
printf '%s\n' "$SSH_PRIVATE_KEY" > "$KEY"
chmod 600 "$KEY"

KNOWN="$ROOT/deploy/known_hosts"
# Host port from api/docker-compose.yml. Not published on the public internet.
REMOTE_PORT=8095
LOCAL_PORT="${NOTES_LOCAL_PORT:-18095}"
ssh -i "$KEY" -p "$DEPLOY_PORT" -o IdentitiesOnly=yes \
  -o UserKnownHostsFile="$KNOWN" -o StrictHostKeyChecking=yes \
  -N -L "${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT}" \
  "${DEPLOY_USER}@${DEPLOY_HOST}" &
TUNNEL_PID=$!
cleanup() {
  kill "$TUNNEL_PID" 2>/dev/null || true
  rm -f "$KEY"
}
trap cleanup EXIT

ready=0
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if curl -sf "http://127.0.0.1:${LOCAL_PORT}/health" >/dev/null; then
    ready=1
    break
  fi
  sleep 0.4
done
if [ "$ready" -ne 1 ]; then
  echo "notes API did not answer /health through the tunnel" >&2
  exit 1
fi

NOTES_API_URL="http://127.0.0.1:${LOCAL_PORT}" python3 -m pytest "$ROOT/api/tests/test_live_notes.py" -q
