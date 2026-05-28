# Contributing

This repository contains two main parts:

- Flutter app in `lib/`, with tests in `test/`.
- Laravel API in `backend/`, with tests in `backend/tests/`.

## Local Workflow

1. Create a feature branch from `main`.
2. Keep Flutter and backend changes separated when possible.
3. Run the relevant checks before committing.
4. Do not commit generated build output, local `.env` files, IDE state, or secrets.

## Flutter Standards

- Keep app code under `lib/` grouped by `core`, `data`, and `presentation`.
- Use existing Riverpod providers and repository patterns before adding new state paths.
- Keep UI text and flow behavior consistent for admin, supervisor, and staff roles.
- Run:

```bash
dart format lib test tool
flutter analyze
flutter test
```

## Laravel Standards

- Keep API logic under `backend/app`, routes in `backend/routes/api.php`, migrations/seeders in `backend/database`, and tests in `backend/tests`.
- Use Sanctum auth and existing role/scoping middleware for protected endpoints.
- Add or update feature tests for API behavior changes.
- Run:

```bash
cd backend
composer test
./vendor/bin/pint --test
```

## Cross-App Integration

- Flutter remote mode expects API URLs in this shape: `https://host.example/api`.
- API response shape changes should be reflected in Flutter models under `lib/data/models` and remote data sources under `lib/data/remote`.
- New fields should support both mock/local data and remote payload parsing.

## Pull Request Checklist

- The change has a clear user-facing or technical purpose.
- `flutter analyze` passes.
- `flutter test` passes.
- Backend tests pass if backend/API code changed.
- No secrets, local databases, generated APKs, or build output are committed.
- README or backend docs are updated if setup, deployment, or behavior changes.

## Issue Labels

Recommended labels:

- `bug`
- `feature`
- `flutter`
- `backend`
- `attendance`
- `security`
- `documentation`
- `ci`
