# Smart Attendance HR API

Laravel backend for the Flutter `smart_attendance_hr_app`.

## Stack

- Laravel 13
- Laravel Sanctum bearer-token auth
- SQLite by default for local development
- MySQL + Redis + Nginx Docker deployment for production

## Local Setup

```bash
cp .env.example .env
php artisan key:generate
mkdir -p database
touch database/database.sqlite
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve --host=127.0.0.1 --port=8000
```

Flutter app:

```bash
flutter run --dart-define=USE_REMOTE_DATA=true --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Android emulator:

```bash
flutter run --dart-define=USE_REMOTE_DATA=true --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## Online Deployment

This repository now includes a production-oriented Docker deployment:

- [Dockerfile](./Dockerfile)
- [docker-compose.production.yml](./docker-compose.production.yml)
- [docker/nginx/default.conf](./docker/nginx/default.conf)
- [.env.production.example](./.env.production.example)
- [DEPLOY_VPS.md](./DEPLOY_VPS.md)
- [TEMP_ONLINE_WITHOUT_DOMAIN.md](./TEMP_ONLINE_WITHOUT_DOMAIN.md)
- public health endpoint: `GET /api/health`

### 1. Server Requirements

- VPS or cloud VM with Docker and Docker Compose
- Public domain or subdomain, for example `api.example.com`
- DNS record pointing to the server

### 2. Prepare Production Environment

```bash
cd backend
cp .env.production.example .env
php artisan key:generate --show
```

Paste the generated key into `.env`, then update at minimum:

- `APP_URL=https://api.example.com`
- `CORS_ALLOWED_ORIGINS=https://your-web-app.example.com`
- `DB_PASSWORD=...`
- `DB_ROOT_PASSWORD=...`
- `MAIL_*` if you plan to send mail
- `AWS_*` if you plan to store uploads in S3

### 3. Start Production Containers

```bash
cd backend
docker compose -f docker-compose.production.yml up -d --build
```

This starts:

- `app` PHP-FPM API container
- `queue` queue worker
- `scheduler` Laravel scheduler loop
- `nginx` public HTTP server
- `mysql` database
- `redis` cache and queue backend

### 4. Put It Behind HTTPS

The included `nginx` container serves plain HTTP on port `80`. For internet-facing production, put it behind:

- Cloudflare + VPS reverse proxy
- host-level Nginx
- Caddy
- Traefik

Then keep these env values:

- `APP_URL=https://api.example.com`
- `APP_FORCE_HTTPS=true`
- `TRUSTED_PROXIES=*`

### 5. Verify It

```bash
curl https://api.example.com/api/health
```

Expected response:

```json
{
  "status": "ok",
  "app": "Smart Attendance HR API",
  "environment": "production"
}
```

## Flutter App Configuration

After the backend is online, run the app with your public API:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/api
```

Or set the same URL inside the app's Settings screen.

## Demo Login

- `identifier`: `admin@smarthr.com`
- `password`: `password123`

`identifier` can be email or mobile. `email` is also accepted for compatibility.

## Auth

### `POST /api/auth/login`

Request:

```json
{
  "identifier": "admin@smarthr.com",
  "password": "password123"
}
```

Response:

```json
{
  "access_token": "token",
  "token_type": "Bearer",
  "user": {},
  "staff": {},
  "session": {}
}
```

Pass the token as:

```http
Authorization: Bearer <access_token>
```

### Session Endpoints

- `GET /api/auth/sessions`
- `POST /api/auth/logout`
- `POST /api/auth/logout-all`
- `DELETE /api/auth/sessions/{tokenId}`
- `POST /api/auth/change-password`

`login` accepts optional `device_name` and `device_id`. If `AUTH_REVOKE_SAME_DEVICE_TOKENS=true`, a new login on the same device replaces the previous token for that device.

## Role Access

- `admin`
  Full read/write access.
- `supervisor`
  Read access to operational data plus leave, expense, overtime, dashboard, and edit-log approvals.
- `staff`
  Self-service flows such as login, check-in/out, notifications, tasks, leaves, expenses, salary, loans, KPI, and holidays read access.

Staff-scoped routes are enforced on the server. If a client sends another employee's `staff_id`, the API denies or auto-scopes the request.
Supervisor-scoped routes are also enforced on the server. Demo supervisor `supervisor@smarthr.com` is assigned to branch `b001` and department `Logistics`, so list reads, approvals, notifications, and attendance actions are limited to that team only.

## Main Routes

Public:

- `GET /api/health`
- `POST /api/auth/login`

Authenticated:

- `GET /api/auth/me`
- `GET /api/auth/sessions`
- `POST /api/auth/logout`
- `POST /api/auth/logout-all`
- `DELETE /api/auth/sessions/{tokenId}`
- `POST /api/auth/change-password`
- `GET /api/branches`
- `GET /api/shifts`
- `GET /api/staff/by-user/{userId}`
- `GET /api/attendance`
- `GET /api/attendance/today`
- `POST /api/attendance/check-in`
- `POST /api/attendance/check-out`
- `GET /api/salaries`
- `GET /api/loans`
- `GET/POST /api/leaves`
- `GET /api/kpis`
- `GET /api/tasks`
- `PATCH /api/tasks/{id}/complete`
- `GET /api/notifications`
- `PATCH /api/notifications/{id}/read`
- `PATCH /api/notifications/read-all`
- `GET/POST /api/expenses`
- `GET /api/holidays`

Supervisor/Admin:

- `GET /api/staff`
- `GET /api/staff/{id}`
- `POST /api/attendance`
- `PUT /api/attendance/{id}`
- `PATCH /api/attendance/{id}/overtime-approval`
- `PATCH /api/leaves/{id}/status`
- `PATCH /api/expenses/{id}/status`
- `GET/POST /api/attendance-edit-logs`
- `PATCH /api/attendance-edit-logs/{id}/status`
- `GET /api/dashboard/stats`

Admin only:

- `POST/PUT /api/branches`
- `POST/PUT /api/shifts`
- `POST/PUT /api/staff`
- `PATCH /api/salaries/{id}/mark-paid`
- `POST /api/salaries/generate`
- `POST /api/loans`
- `POST /api/tasks/assign`
- `PATCH /api/tasks/{id}/terminate`
- `POST /api/holidays`
- `DELETE /api/holidays/{id}`

## Environment Notes

- `DB_DATABASE=database/database.sqlite`
- `SANCTUM_TOKEN_EXPIRATION=10080`
  Example above is 7 days in minutes.
- `AUTH_REVOKE_SAME_DEVICE_TOKENS=true`
- `AUTH_DEFAULT_DEVICE_NAME=mobile-app`
- `CORS_ALLOWED_ORIGINS=*`
  Replace `*` with comma-separated origins in production.
- `APP_URL=http://127.0.0.1:8000`
- `APP_FORCE_HTTPS=true`
  Enable when SSL terminates at a proxy or public HTTPS domain.
- `TRUSTED_PROXIES=*`
  Required behind load balancers / reverse proxies.
- `APP_TIMEZONE=Asia/Muscat`
  Keeps backend timestamps aligned with your target region.

## Verification

```bash
php artisan migrate:fresh --seed
php artisan route:list --path=api
php artisan test
```
