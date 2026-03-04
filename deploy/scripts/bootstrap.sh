#!/usr/bin/env bash
# ALL-IN-ONE setup + deploy for Hetzner VPS.
# Usage: ssh root@YOUR_IP 'bash -s' <<< "$(curl -fsSL https://raw.githubusercontent.com/gregoryforel/fondra/main/deploy/scripts/bootstrap.sh)"
#
# Or paste the whole thing into your SSH terminal.
#
# You MUST set these two variables before running:
DOMAIN="${DOMAIN:?Set DOMAIN=your-domain.com before running}"
REPO_URL="${REPO_URL:-https://github.com/gregoryforel/fondra.git}"
DB_PASSWORD="$(openssl rand -base64 24)"

set -euo pipefail
APP_DIR="/srv/recipes"
DEPLOY_USER="deploy"

echo "============================================"
echo "  Recipe Platform — Full Bootstrap"
echo "  Domain: $DOMAIN"
echo "============================================"
echo ""

# --- 1. System ---
echo "[1/8] Updating system..."
apt-get update -qq && apt-get upgrade -y -qq

# --- 2. Docker ---
echo "[2/8] Installing Docker..."
if ! command -v docker &>/dev/null; then
    apt-get install -y -qq ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker && systemctl start docker
fi
echo "  Docker: $(docker --version)"

# --- 3. Deploy user ---
echo "[3/8] Creating deploy user..."
if ! id "$DEPLOY_USER" &>/dev/null; then
    useradd --create-home --shell /bin/bash "$DEPLOY_USER"
fi
usermod -aG docker "$DEPLOY_USER"
DEPLOY_HOME=$(eval echo "~$DEPLOY_USER")
mkdir -p "$DEPLOY_HOME/.ssh"
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys "$DEPLOY_HOME/.ssh/authorized_keys"
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_HOME/.ssh"
    chmod 700 "$DEPLOY_HOME/.ssh" && chmod 600 "$DEPLOY_HOME/.ssh/authorized_keys"
fi

# --- 4. Firewall ---
echo "[4/8] Configuring firewall..."
apt-get install -y -qq ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# --- 5. Clone repo ---
echo "[5/8] Cloning repository..."
mkdir -p "$APP_DIR"
chown "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"
if [ -d "$APP_DIR/.git" ]; then
    echo "  Repo already cloned, pulling latest..."
    su - "$DEPLOY_USER" -c "cd $APP_DIR && git pull origin main"
else
    su - "$DEPLOY_USER" -c "git clone $REPO_URL $APP_DIR"
fi

# --- 6. Create .env ---
echo "[6/8] Creating .env..."
cat > "$APP_DIR/.env" <<ENVEOF
DOMAIN=$DOMAIN
POSTGRES_USER=recipe
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=recipe_platform
ENVEOF
chown "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR/.env"
chmod 600 "$APP_DIR/.env"

# --- 7. Build and start ---
echo "[7/8] Building and starting containers..."
su - "$DEPLOY_USER" -c "cd $APP_DIR && docker compose -f deploy/docker-compose.prod.yml up -d --build"

# Wait for health
echo "  Waiting for app to be healthy..."
for i in $(seq 1 30); do
    if su - "$DEPLOY_USER" -c "docker compose -f $APP_DIR/deploy/docker-compose.prod.yml exec -T app wget -qO- http://localhost:8080/health" 2>/dev/null | grep -q healthy; then
        echo "  App is healthy!"
        break
    fi
    sleep 2
done

# --- 8. Migrate + seed + compile ---
echo "[8/8] Running migrations, seed, and recipe compilation..."
su - "$DEPLOY_USER" -c "docker compose -f $APP_DIR/deploy/docker-compose.prod.yml exec -T app sh -c '
    for f in /app/db/migrations/*_*.up.sql; do
        PGPASSWORD=\$POSTGRES_PASSWORD psql -h postgres -U \$POSTGRES_USER -d \$POSTGRES_DB -f \"\$f\" 2>&1
    done
'"

su - "$DEPLOY_USER" -c "docker compose -f $APP_DIR/deploy/docker-compose.prod.yml exec -T app sh -c '
    for f in /app/db/seed/*.sql; do
        PGPASSWORD=\$POSTGRES_PASSWORD psql -h postgres -U \$POSTGRES_USER -d \$POSTGRES_DB -f \"\$f\" 2>&1
    done
'"

su - "$DEPLOY_USER" -c "docker compose -f $APP_DIR/deploy/docker-compose.prod.yml exec -T app /app/server compile-recipes"

echo ""
echo "============================================"
echo "  DONE!"
echo "============================================"
echo ""
echo "  URL:          https://$DOMAIN"
echo "  Health:       https://$DOMAIN/health"
echo "  DB password:  $DB_PASSWORD"
echo ""
echo "  SAVE THE DB PASSWORD ABOVE — it won't be shown again."
echo "  (It's also in $APP_DIR/.env)"
echo ""
echo "  To check status:  ssh deploy@$(hostname -I | awk '{print $1}') 'cd $APP_DIR && docker compose -f deploy/docker-compose.prod.yml ps'"
echo "============================================"
