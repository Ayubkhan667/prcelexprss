# Android APK Signing

The app can build a local release APK without a production keystore because `android/app/build.gradle.kts` falls back to the debug signing config when `android/key.properties` is missing. Use that only for testing.

For Play Store or production distribution, create and protect a real upload keystore.

## 1. Generate Keystore

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

## 2. Configure Local Signing

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties`:

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/Users/you/upload-keystore.jks
```

`android/key.properties`, `*.jks`, and `*.keystore` are ignored by git.

## 3. Build Signed APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## CI Notes

The included `android-release.yml` workflow builds a release APK artifact using the repository build config. For production signing in CI, store keystore material in GitHub Actions secrets and decode it during the workflow before running `flutter build apk --release`.
