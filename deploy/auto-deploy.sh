#!/usr/bin/env bash
# Auto-deploy iago-cavalcante (site pessoal) on ssh-tron.
# Triggered by .github/workflows/deploy.yml via the self-hosted Actions
# runner on push to main. Modeled on nutrafluxo's deploy/auto-deploy.sh.
set -euo pipefail

REPO=/home/tron/Workspaces/IagoCavalcante/iago-cavalcante
COMPOSE="docker compose -f docker-compose.hostnet.yml"
SERVICE=site

cd "$REPO"
git fetch origin main --quiet

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" = "$REMOTE" ]; then
  exit 0
fi

echo "[$(date -Is)] new commits on main: ${LOCAL:0:7} -> ${REMOTE:0:7}"
git pull --ff-only origin main

echo "[$(date -Is)] rebuilding $SERVICE"
$COMPOSE build "$SERVICE"
$COMPOSE up -d "$SERVICE"

for i in 1 2 3 4 5; do
  sleep 3
  if curl -sf -m 10 -H 'Host: iagocavalcante.com' http://127.0.0.1:4020/ >/dev/null; then
    echo "[$(date -Is)] deploy OK at $(git rev-parse --short HEAD)"
    exit 0
  fi
done

echo "[$(date -Is)] DEPLOY FAILED: health check did not pass"
exit 1
