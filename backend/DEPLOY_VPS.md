# VPS Deployment Guide

This guide deploys the Smart Attendance HR API online on an Ubuntu VPS with:

- Docker
- Docker Compose
- Caddy for HTTPS
- Public domain such as `api.example.com`

The backend already includes:

- [Dockerfile](./Dockerfile)
- [docker-compose.production.yml](./docker-compose.production.yml)
- [production env template](./.env.production.example)

## 1. Assumptions

- VPS OS: Ubuntu 24.04 or Ubuntu 22.04
- Domain/subdomain: `api.example.com`
- App repository available on the server
- You want HTTPS

## 2. Point DNS to Server

Create an `A` record:

- Host: `api`
- Value: `YOUR_SERVER_PUBLIC_IP`

Wait until DNS resolves:

```bash
ping api.example.com
```

## 3. Login to VPS

```bash
ssh root@YOUR_SERVER_PUBLIC_IP
```

Or with a sudo user:

```bash
ssh ubuntu@YOUR_SERVER_PUBLIC_IP
```

## 4. Install Base Packages

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release git ufw
```

## 5. Install Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

Optional, so your current user can run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 6. Install Caddy for HTTPS

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
```

## 7. Open Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
```

## 8. Upload or Clone Project

Example:

```bash
cd /opt
sudo git clone YOUR_REPO_URL smart_attendance_hr_app
sudo chown -R $USER:$USER /opt/smart_attendance_hr_app
cd /opt/smart_attendance_hr_app/backend
```

## 9. Create Production Environment File

```bash
cp .env.production.example .env
```

Generate a Laravel app key:

```bash
echo "base64:$(openssl rand -base64 32)"
```

Copy that generated value into `.env` as `APP_KEY=...`

Now edit `.env`:

```bash
nano .env
```

Set these values at minimum:

```env
APP_NAME="Smart Attendance HR API"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.example.com
APP_FORCE_HTTPS=true
APP_TIMEZONE=Asia/Muscat
TRUSTED_PROXIES=*

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=smart_attendance_hr
DB_USERNAME=smart_hr_user
DB_PASSWORD=strong-app-password
DB_ROOT_PASSWORD=strong-root-password

QUEUE_CONNECTION=redis
CACHE_STORE=redis
FILESYSTEM_DISK=public

CORS_ALLOWED_ORIGINS=https://your-web-app-domain.com
APP_HTTP_PORT=8080
```

Notes:

- `APP_HTTP_PORT=8080` is important because Caddy will use ports `80` and `443` on the host.
- If you do not have a web panel/domain yet, you can temporarily use `CORS_ALLOWED_ORIGINS=*` for testing only.

## 10. Start Backend Containers

```bash
docker compose -f docker-compose.production.yml up -d --build
```

Check status:

```bash
docker compose -f docker-compose.production.yml ps
```

Check logs:

```bash
docker compose -f docker-compose.production.yml logs -f app
```

## 11. Configure Caddy Reverse Proxy

Open Caddy config:

```bash
sudo nano /etc/caddy/Caddyfile
```

Put this:

```caddy
api.example.com {
    reverse_proxy 127.0.0.1:8080
}
```

Reload Caddy:

```bash
sudo systemctl reload caddy
```

Check status:

```bash
sudo systemctl status caddy
```

## 12. Verify Public API

Health check:

```bash
curl https://api.example.com/api/health
```

Expected shape:

```json
{
  "status": "ok",
  "app": "Smart Attendance HR API",
  "environment": "production"
}
```

Test login:

```bash
curl -X POST https://api.example.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@smarthr.com","password":"password123"}'
```

## 13. Connect Flutter App

Use this API URL in the mobile app:

```text
https://api.example.com/api
```

Or run Flutter directly with:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/api
```

## 14. Important Production Notes

- Keep `APP_DEBUG=false`
- Use strong DB passwords
- Replace demo seeded accounts before going live
- Restrict `CORS_ALLOWED_ORIGINS` to your real frontend domains
- Back up MySQL and Docker volumes
- Keep only one public entrypoint: Caddy on `80/443`
- Do not expose MySQL or Redis to the public internet

## 15. Useful Commands

Restart stack:

```bash
docker compose -f docker-compose.production.yml restart
```

Rebuild after code update:

```bash
git pull
docker compose -f docker-compose.production.yml up -d --build
```

Run migrations manually:

```bash
docker compose -f docker-compose.production.yml exec app php artisan migrate --force
```

View Laravel logs:

```bash
docker compose -f docker-compose.production.yml exec app tail -f storage/logs/laravel.log
```

Open Laravel shell:

```bash
docker compose -f docker-compose.production.yml exec app php artisan tinker
```
