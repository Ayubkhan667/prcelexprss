# Screenshots

Product screenshots are generated from Flutter widget renders for README usage:

- `admin-dashboard.png`
- `task-cards.png`
- `backup-export.png`
- `settings.png`

Regenerate them with:

```bash
flutter test --update-goldens tool/readme_screenshots_test.dart
```

Do not include screenshots with real employee personal data, production URLs, access tokens, or private company information.
