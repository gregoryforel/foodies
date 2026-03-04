# Deployment

Production runs on a Hetzner VPS with Docker Compose.

## Architecture

```
internet → Cloudflare (DNS + CDN) → Caddy (TLS + reverse proxy) → Go app → Postgres
```

- **Caddy** is the only container exposing ports (80, 443)
- **Postgres** runs on an internal Docker network — no public access
- **Go app** listens on :8080 internally

## First-time server setup

### 1. Provision a Hetzner VPS

- Ubuntu 22.04+ (or 24.04)
- Minimum: CX22 (2 vCPU, 4GB RAM) — sufficient for v0
- Add your SSH public key during creation

### 2. Run the server setup script

```bash
ssh root@YOUR_SERVER_IP 'bash -s' < deploy/scripts/server-setup.sh
```

This installs Docker, creates a `deploy` user, configures UFW firewall, and creates `/srv/recipes`.

### 3. Clone the repo on the server

```bash
ssh deploy@YOUR_SERVER_IP
cd /srv/recipes
git clone https://github.com/YOUR_ORG/fondra.git .
```

### 4. Create production .env

```bash
cp .env.example .env
```

Edit `.env` and set:

```
DOMAIN=recipes.yourdomain.com
POSTGRES_USER=recipe
POSTGRES_PASSWORD=a-strong-random-password
POSTGRES_DB=recipe_platform
```

### 5. Point DNS

In Cloudflare (or your DNS provider):
- `A` record: `recipes.yourdomain.com` → `YOUR_SERVER_IP`
- Proxy status: DNS only (orange cloud OFF) initially, so Caddy can get a Let's Encrypt cert
- After cert is issued, you can enable Cloudflare proxy if desired

### 6. Deploy

```bash
cd /srv/recipes
docker compose -f deploy/docker-compose.prod.yml up -d
```

### 7. Run migrations and seed

```bash
docker compose -f deploy/docker-compose.prod.yml exec app sh -c '
  for f in /app/db/migrations/*_*.up.sql; do
    PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -f "$f"
  done
'

docker compose -f deploy/docker-compose.prod.yml exec app sh -c '
  for f in /app/db/seed/*.sql; do
    PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -f "$f"
  done
'

# Compile recipes
docker compose -f deploy/docker-compose.prod.yml exec app /app/server compile-recipes
```

### 8. Verify

```bash
curl https://recipes.yourdomain.com/health
# → {"status":"healthy"}
```

## CI/CD (GitHub Actions)

Pushes to `main` trigger automatic deployment.

### Required GitHub secrets

Go to repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|-------|
| `HOST` | Your Hetzner server IP |
| `DEPLOY_USER` | `deploy` |
| `DEPLOY_KEY` | Private SSH key for the deploy user |

### How it works

1. Tests run (build + `go test`)
2. If tests pass and branch is `main`, SSH into the server
3. Runs `deploy/scripts/deploy.sh` on the server
4. Script pulls latest code, rebuilds containers, restarts, runs migrations

### Manual deploy

```bash
ssh deploy@YOUR_SERVER_IP 'bash /srv/recipes/deploy/scripts/deploy.sh'
```

## Rollback

```bash
ssh deploy@YOUR_SERVER_IP
cd /srv/recipes
git log --oneline -5          # Find the commit to roll back to
git checkout <commit-hash>
docker compose -f deploy/docker-compose.prod.yml build
docker compose -f deploy/docker-compose.prod.yml up -d
```

## Monitoring

```bash
# Container status
make deploy-ps

# Logs (all containers)
make deploy-logs

# Just the app logs
docker compose -f deploy/docker-compose.prod.yml logs -f app

# Health check
curl https://recipes.yourdomain.com/health
```

## Backups

Postgres data is in a Docker named volume `pgdata`. To back up:

```bash
docker compose -f deploy/docker-compose.prod.yml exec postgres \
  pg_dump -U recipe recipe_platform > backup_$(date +%Y%m%d).sql
```
