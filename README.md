# Parcel Express Smart Attendance HR

Flutter mobile/web app with a Laravel API backend for attendance, HR operations, task cards, KPI tracking, notifications, payroll support, and staff self-service.

## Project Structure

```text
.
├── lib/                 # Flutter application code
├── test/                # Flutter widget and unit tests
├── assets/              # Flutter images/assets
├── android/ ios/ web/   # Flutter platform projects
├── backend/             # Laravel API, migrations, seeders, tests, Docker deploy
└── .github/workflows/   # CI checks
```

## Main Features

- Role-based app flows for admin, supervisor, and staff.
- Attendance check-in/out with selfie, office Wi-Fi verification, geofence/range validation, fake GPS checks, and device binding.
- Employee-specific attendance range and daily break limit managed by admin.
- Outside assigned range: normal Check In/Out is blocked; only Visit and Break actions are allowed.
- Admin task cards, daily termination, task assignment to one employee or all employees, and task contribution to KPI.
- KPI dashboard with task-first score weighting, attendance, punctuality, overtime, location, and discipline.
- Leave, overtime, expense, salary, loan, holiday, notification, and attendance edit-log flows.
- Expense approvals, employee payslip PDF export, attendance correction requests, shift roster/swap requests, document expiry alerts, announcements, and helpdesk tickets.
- Laravel Sanctum API with token/session hardening and role-scoped routes.
- Firebase Messaging client plumbing with backend push token registration.

## Requirements

- Flutter stable SDK with Dart 3.
- Android Studio or Xcode for platform builds.
- PHP 8.3 or newer.
- Composer.
- Node.js 22 or compatible Node version for Laravel/Vite assets.
- SQLite for local backend development, or MySQL/Redis for production Docker deployment.

## Flutter Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Run with local Laravel API:

```bash
flutter run \
  --dart-define=USE_REMOTE_DATA=true \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Android emulator against local Laravel API:

```bash
flutter run \
  --dart-define=USE_REMOTE_DATA=true \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Build APK:

```bash
flutter build apk --release
```

For production signing, follow [Android APK Signing](docs/APK_SIGNING.md).

## Backend Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
mkdir -p database
touch database/database.sqlite
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve --host=127.0.0.1 --port=8000
```

Run backend quality checks:

```bash
cd backend
composer test
./vendor/bin/pint --test
```

Build backend frontend assets:

```bash
cd backend
npm install --ignore-scripts
npm run build
```

## Demo Login

- Admin: `admin@smarthr.com`
- Supervisor: `supervisor@smarthr.com`
- Staff: `staff@smarthr.com`
- Demo password: `password123`

Demo credentials are for local seeded data only. Change all seeded/default credentials before production use.

## Environment Configuration

Flutter remote backend is configured with Dart defines:

- `USE_REMOTE_DATA=true`
- `API_BASE_URL=https://your-api-domain.example/api`

Laravel environment is configured in `backend/.env`. Start from `backend/.env.example` and never commit real `.env` files.

Production deployment docs:

- [Backend README](backend/README.md)
- [VPS deployment guide](backend/DEPLOY_VPS.md)
- [Temporary online setup without domain](backend/TEMP_ONLINE_WITHOUT_DOMAIN.md)
- [API reference](docs/API.md)
- [App demo flow](docs/APP_DEMO.md)
- [Push notification setup](docs/PUSH_NOTIFICATIONS.md)
- [Screenshot capture guide](docs/screenshots/README.md)

## Screenshots And Demo

Sanitized app screenshots are stored under `docs/screenshots/`. The demo flow is documented in [docs/APP_DEMO.md](docs/APP_DEMO.md).

| Screen | File |
| --- | --- |
| Admin Dashboard | `docs/screenshots/admin-dashboard.png` |
| Task Cards | `docs/screenshots/task-cards.png` |
| Backup & Export | `docs/screenshots/backup-export.png` |
| Settings | `docs/screenshots/settings.png` |

## Testing And CI

GitHub Actions runs:

- Flutter dependency install, format check, static analysis, and tests.
- Laravel Composer install, environment setup, PHPUnit tests, and Pint style check.
- Manual/tagged Android release APK artifact build.
- Weekly Dependabot checks for Flutter, Composer, npm, and GitHub Actions.

Local commands before pushing:

```bash
dart format lib test tool
flutter analyze
flutter test

cd backend
composer test
./vendor/bin/pint --test
```

## Security

- Do not commit `.env`, API keys, database passwords, signing keys, upload secrets, or production credentials.
- Use GitHub Actions secrets or server environment variables for production secrets.
- Keep Flutter, Composer, and npm dependencies updated.
- Review `SECURITY.md` before reporting or fixing security issues.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, coding standards, testing expectations, and module ownership.
