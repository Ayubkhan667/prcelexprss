# API Reference

Base URL:

```text
https://your-api-domain.example/api
```

Local URL:

```text
http://127.0.0.1:8000/api
```

Authentication uses Laravel Sanctum bearer tokens:

```http
Authorization: Bearer <access_token>
```

## Auth

### `POST /auth/login`

```json
{
  "identifier": "admin@smarthr.com",
  "password": "password123",
  "device_name": "mobile-app",
  "device_id": "device-id"
}
```

Returns `access_token`, `user`, `staff`, and `session`.

### Session And Password Routes

- `GET /auth/me`
- `GET /auth/sessions`
- `POST /auth/logout`
- `POST /auth/logout-all`
- `DELETE /auth/sessions/{tokenId}`
- `POST /auth/change-password`
- `POST /auth/biometric-token`
- `DELETE /auth/biometric-token`

## Staff

Admin and supervisor routes:

- `GET /staff`
- `GET /staff/{id}`
- `POST /staff`
- `PUT /staff/{id}`
- `POST /staff/{id}/reset-device-binding`

Self/common route:

- `GET /staff/by-user/{userId}`

Staff payload is wrapped when creating/updating:

```json
{
  "staff": {
    "name": "Example Staff",
    "email": "staff@example.com",
    "mobile": "+968 9000 0000",
    "staff_code": "SHR-100",
    "job_title": "Driver",
    "category": "Driver",
    "department": "Operations",
    "branch_id": "b001",
    "shift_id": "s001",
    "allowed_location_radius_meters": 150,
    "daily_break_minutes": 60,
    "joining_date": "2026-05-28T00:00:00.000Z",
    "basic_salary": 350,
    "overtime_rate": 2,
    "weekly_off_day": "Friday",
    "status": "Active"
  },
  "user": {
    "name": "Example Staff",
    "email": "staff@example.com",
    "mobile": "+968 9000 0000",
    "role": "staff",
    "status": "Active"
  }
}
```

Range fields:

- `allowed_location_radius_meters`: optional employee-specific radius. If null, app uses the assigned branch radius.
- `daily_break_minutes`: per-day break allowance shown and enforced by the app flow.

## Attendance

- `GET /attendance`
- `GET /attendance/today`
- `POST /attendance/check-in`
- `POST /attendance/check-out`
- `POST /attendance/{id}/pause`
- `POST /attendance/{id}/resume`
- `POST /attendance`
- `PUT /attendance/{id}`
- `PATCH /attendance/{id}/overtime-approval`

Check-in/out form fields:

- `staff_id`
- `shift_id`
- `event_time`
- `latitude`
- `longitude`
- `device_id`
- `is_location_valid`
- `is_mock_gps`
- `wifi_ssid`
- `selfie`
- `notes`

Client behavior:

- Check In/Out requires matching assigned range and office Wi-Fi.
- Outside assigned range, the Flutter app blocks normal Check In/Out and allows only Visit or Break actions.
- Break uses attendance pause/resume fields.
- Visit is recorded as an attendance status/note for the day.

## Core HR Routes

Branches:

- `GET /branches`
- `POST /branches`
- `PUT /branches/{id}`

Shifts:

- `GET /shifts`
- `POST /shifts`
- `PUT /shifts/{id}`

Tasks:

- `GET /tasks`
- `POST /tasks/assign`
- `PATCH /tasks/{id}/complete`
- `PATCH /tasks/{id}/terminate`

Notifications:

- `GET /notifications`
- `PATCH /notifications/{id}/read`
- `PATCH /notifications/read-all`
- `POST /announcements`

Leaves, expenses, payroll, and holidays:

- `GET/POST /leaves`
- `PATCH /leaves/{id}/status`
- `GET/POST /expenses`
- `PATCH /expenses/{id}/status`
- `GET /salaries`
- `PATCH /salaries/{id}/mark-paid`
- `POST /salaries/generate`
- `GET /loans`
- `POST /loans`
- `GET /holidays`
- `POST /holidays`
- `DELETE /holidays/{id}`

Rosters, swaps, helpdesk, and push tokens:

- `GET /shift-rosters`
- `POST /shift-rosters`
- `PUT /shift-rosters/{id}`
- `GET /shift-swap-requests`
- `POST /shift-swap-requests`
- `PATCH /shift-swap-requests/{id}/status`
- `GET /helpdesk-tickets`
- `POST /helpdesk-tickets`
- `PATCH /helpdesk-tickets/{id}/status`
- `POST /push-tokens`
- `DELETE /push-tokens`

## Role Scope

- `admin`: full read/write access.
- `supervisor`: branch/team-scoped operational access.
- `staff`: self-scoped access only.

Server-side scoping rejects requests outside the authenticated user role and assigned branch/team.
