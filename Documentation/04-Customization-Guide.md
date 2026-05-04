## Customization Guide

This guide explains how CodeCanyon buyers can customize branding, styling, and configuration for the CampusHub Pro / book sale template.

### 1. Change App Name and Bundle IDs

- **Android**
  - Open `book_user_app/android/app/build.gradle.kts`.
  - Update the `applicationId` to your own (for example `com.yourcompany.marketplace`).
  - Update app name in:
    - `android/app/src/main/res/values/strings.xml` (`app_name`).
- **iOS**
  - Open the iOS project in Xcode (`book_user_app/ios`).
  - Select the `Runner` target and change:
    - **Display Name** – shown under the app icon.
    - **Bundle Identifier** – must match the one you use in Firebase and in your provisioning profile.

### 2. Update Icons and Splash Screens

- Replace launcher icons and splash assets with your own branding.
- You can use community packages like `flutter_launcher_icons` and `flutter_native_splash`, or manually replace images in the Android/iOS projects.

### 3. Configure Backend URL (API_BASE_URL)

The mobile app reads the base URL for the backend from an environment/config helper:

- File: `book_user_app/lib/config/app_environment.dart`

You should pass your API URL at build time using a Dart define:

```bash
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
```

For local development, sensible defaults are provided:

- Android emulator: `http://10.0.2.2:5000`
- iOS simulator / web: `http://localhost:5000`

Update `02-Installation-Backend.md` and this guide with the URL you actually deploy to in production.

### 4. Configure Google Maps API Key

Map previews (for example in chat location messages) use a static maps URL.

- File: `book_user_app/lib/config/maps_config.dart`

Steps:

1. Obtain a Google Maps API key in Google Cloud Console.
2. Restrict the key to:
   - Maps Static API (and any other used Maps SDKs).
   - Your Android SHA‑1 fingerprints and/or iOS bundle identifiers.
3. Replace:

```dart
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

with your own key.

Never commit a real unrestricted key to a public repository.

### 5. Theme and Color Customization

- Primary theming is defined in:
  - `book_user_app/lib/config/theme/app_theme.dart`
  - `book_user_app/lib/core/theme/app_palette.dart`

You can:

- Change primary/accent colors.
- Adjust typography scales, corner radii, and elevations.
- Toggle dark mode defaults (via `ThemeCubit`).

Use `flutter_screenutil` helpers consistently (`.w`, `.h`, `.sp`) when you add or modify widgets to keep spacing and typography responsive.

### 6. Localization and Text

- Localization files live under:
  - `book_user_app/lib/l10n/`

To customize texts:

1. Edit the existing localization ARB/Dart files for each language.
2. Regenerate localizations if you add new keys (using Flutter’s localization tooling).

Avoid hardcoded user‑facing strings in widgets; instead, route them through `AppLocalizations`.

### 7. Feature Toggles (Optional)

If you want to expose configuration flags (for example to disable promotions, Google OAuth, or certain filters), add them to a simple config class, e.g.:

- `book_user_app/lib/config/app_config.dart`

and read them from UI or BLoCs to show/hide features. This makes it easier for buyers to tailor the template without editing core business logic.

