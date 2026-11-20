#!/usr/bin/env bash
# Push to main runs this from GitHub Actions.
# Copies only api/ to DEPLOY_PATH and rebuilds that container.
# The static site stays on Cloudflare Pages.
set -euo pipefail

: "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}"
: "${DEPLOY_HOST:?DEPLOY_HOST is required}"
: "${DEPLOY_USER:?DEPLOY_USER is required}"
: "${DEPLOY_PORT:?DEPLOY_PORT is required}"
: "${DEPLOY_PATH:?DEPLOY_PATH is required}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY="$(mktemp)"
trap 'rm -f "$KEY"' EXIT
printf '%s\n' "$SSH_PRIVATE_KEY" > "$KEY"
chmod 600 "$KEY"

KNOWN="$ROOT/deploy/known_hosts"
SSH_OPTS=(
  -i "$KEY"
  -p "$DEPLOY_PORT"
  -o IdentitiesOnly=yes
  -o UserKnownHostsFile="$KNOWN"
  -o StrictHostKeyChecking=yes
  -o ServerAliveInterval=30
  -o ServerAliveCountMax=120
)
export RSYNC_RSH="ssh -i $KEY -p $DEPLOY_PORT -o IdentitiesOnly=yes -o UserKnownHostsFile=$KNOWN -o StrictHostKeyChecking=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=120"

ssh "${SSH_OPTS[@]}" "${DEPLOY_USER}@${DEPLOY_HOST}" "mkdir -p '$DEPLOY_PATH'"

rsync -az --delete \
  --exclude __pycache__/ \
  --exclude .venv/ \
  --exclude tests/ \
  "$ROOT/api/" "${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/"

# Build can take several minutes (audio libraries). Health is checked after compose returns.
# 8095 is the host port in api/docker-compose.yml.
ssh "${SSH_OPTS[@]}" "${DEPLOY_USER}@${DEPLOY_HOST}" \
  "DEPLOY_PATH='$DEPLOY_PATH' bash -s" <<'EOF'
set -euo pipefail
cd "$DEPLOY_PATH"
docker compose up -d --build
deadline=$((SECONDS + 90))
while true; do
  health=$(curl -sf http://127.0.0.1:8095/health || true)
  if [ -n "$health" ]; then
    printf '%s\n' "$health"
    exit 0
  fi
  if (( SECONDS >= deadline )); then
    echo "notes API did not answer /health on port 8095 within 90s" >&2
    docker compose ps || true
    docker compose logs --tail=80 || true
    exit 1
  fi
  sleep 2
done
EOF
