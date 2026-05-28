# Push Notifications Setup

The app now includes Firebase Cloud Messaging client plumbing and backend push token registration.

## Flutter Client

1. Add your Firebase project files:
   - Android: `android/app/google-services.json`
   - iOS/macOS: `ios/Runner/GoogleService-Info.plist` and `macos/Runner/GoogleService-Info.plist` if used
2. Enable Cloud Messaging in the Firebase console.
3. Run `flutter pub get`.

The app initializes Firebase Messaging defensively. If Firebase is not configured, the app continues running and push registration is skipped.

## Backend

The Laravel API stores device push tokens through:

- `POST /api/push-tokens`
- `DELETE /api/push-tokens`

Current implementation covers token registration and app-side receive handling. If you want server-initiated FCM delivery, wire your preferred Firebase sender implementation to the existing notification creation flow in `HrModuleController`.
