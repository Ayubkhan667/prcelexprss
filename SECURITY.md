# Security Policy

## Supported Scope

Security reports should focus on the current `main` branch and production-relevant code in:

- Flutter app authentication, local storage, biometric login, device binding, attendance capture, and API clients.
- Laravel API authentication, authorization, staff scoping, attendance endpoints, file upload handling, and deployment configuration.

## Reporting A Vulnerability

Do not open a public issue for sensitive security problems. Report privately to the repository owner or maintainer.

Include:

- Affected area or endpoint.
- Steps to reproduce.
- Expected impact.
- Any logs, screenshots, or proof-of-concept details that do not expose real secrets.

## Secret Handling

- Never commit `.env`, production API URLs with credentials, database dumps, signing keys, private keys, or access tokens.
- Store production values in server environment variables or GitHub Actions secrets.
- Rotate secrets immediately if they are accidentally committed.

## Dependency Hygiene

Run these checks regularly:

```bash
flutter pub outdated

cd backend
composer audit
npm audit
```

Review dependency upgrades before production deployment.

## Production Baseline

- Use HTTPS for the API.
- Set `APP_DEBUG=false`.
- Set strong database and Redis passwords.
- Replace demo credentials and seeded passwords.
- Restrict `CORS_ALLOWED_ORIGINS` to trusted app domains.
- Keep `AUTH_REVOKE_SAME_DEVICE_TOKENS=true` unless there is a clear operational reason to change it.
