#!/usr/bin/env bash
# Hetzner VPS initial setup script.
# Idempotent — safe to run multiple times.
#
# Usage: ssh root@your-server 'bash -s' < deploy/scripts/server-setup.sh
#
# What this does:
#   1. Updates system packages
#   2. Installs Docker + Docker Compose plugin
#   3. Creates a deploy user with docker access
#   4. Sets up UFW firewall (SSH, HTTP, HTTPS only)
#   5. Creates application directory /srv/recipes

set -euo pipefail

APP_DIR="/srv/recipes"
DEPLOY_USER="deploy"

echo "=== Recipe Platform — Server Setup ==="

# -------------------------------------------------------
# 1. System updates
# -------------------------------------------------------
echo "[1/5] Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

# -------------------------------------------------------
# 2. Install Docker (if not present)
# -------------------------------------------------------
echo "[2/5] Installing Docker..."
if command -v docker &>/dev/null; then
    echo "  Docker already installed: $(docker --version)"
else
    apt-get install -y -qq ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
    fi
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
            > /etc/apt/sources.list.d/docker.list
        apt-get update -qq
    fi
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    echo "  Docker installed: $(docker --version)"
fi

# -------------------------------------------------------
# 3. Create deploy user (if not present)
# -------------------------------------------------------
echo "[3/5] Setting up deploy user..."
if id "$DEPLOY_USER" &>/dev/null; then
    echo "  User '$DEPLOY_USER' already exists"
else
    useradd --create-home --shell /bin/bash "$DEPLOY_USER"
    echo "  User '$DEPLOY_USER' created"
fi

# Add to docker group
usermod -aG docker "$DEPLOY_USER"

# Copy root's authorized_keys to deploy user (so the same SSH key works)
DEPLOY_HOME=$(eval echo "~$DEPLOY_USER")
mkdir -p "$DEPLOY_HOME/.ssh"
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys "$DEPLOY_HOME/.ssh/authorized_keys"
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_HOME/.ssh"
    chmod 700 "$DEPLOY_HOME/.ssh"
    chmod 600 "$DEPLOY_HOME/.ssh/authorized_keys"
    echo "  SSH keys copied to deploy user"
fi

# -------------------------------------------------------
# 4. Firewall (UFW)
# -------------------------------------------------------
echo "[4/5] Configuring firewall..."
apt-get install -y -qq ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw --force enable
echo "  UFW enabled: SSH(22), HTTP(80), HTTPS(443)"

# -------------------------------------------------------
# 5. Application directory
# -------------------------------------------------------
echo "[5/5] Creating application directory..."
mkdir -p "$APP_DIR"
chown "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"
echo "  $APP_DIR ready (owned by $DEPLOY_USER)"

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Add your repo as a git remote on the server:"
echo "     su - $DEPLOY_USER"
echo "     cd $APP_DIR"
echo "     git clone <your-repo-url> ."
echo ""
echo "  2. Create .env with production secrets:"
echo "     cp .env.example .env"
echo "     # Edit .env: set POSTGRES_PASSWORD, DOMAIN, etc."
echo ""
echo "  3. Start the application:"
echo "     docker compose -f deploy/docker-compose.prod.yml up -d"
echo ""
echo "  4. Run migrations and seed:"
echo "     docker compose -f deploy/docker-compose.prod.yml exec app /app/server migrate"
echo "     # Or use psql from the app container"
