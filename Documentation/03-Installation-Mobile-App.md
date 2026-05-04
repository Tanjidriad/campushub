## Mobile App Installation – `book_user_app`

This document explains how to run the Flutter mobile app and connect it to your backend API.

### 1. Prerequisites

- **Flutter SDK**: 3.10.x or newer (matching the constraint in `pubspec.yaml`).
- **Android Studio / Xcode**: for Android and iOS tooling.
- **A running backend API**: see `02-Installation-Backend.md`.

### 2. Install Flutter Dependencies

```bash
cd book_user_app
flutter pub get
```

### 3. Configure API Base URL

The app talks to the backend through a centralized configuration. You must point it to your backend server URL.

1. Open the environment/config file (see `lib/config/app_environment.dart` or equivalent).
2. Set the value of `API_BASE_URL` (for example):
   - `http://10.0.2.2:5000` for Android emulator.
   - `http://localhost:5000` for iOS simulator.
   - Your production domain, such as `https://api.yourdomain.com`, for release builds.
3. Rebuild the app after changing this value.

Refer to the comments in the config file for the recommended way to pass this value using `--dart-define` at build time.

### 4. Configure Google Maps API Key

If you want to enable map previews (for example in chat location messages), you must provide your own **Google Maps API key**:

1. Create a key in Google Cloud Console and restrict it to:
   - Maps Static API (and any other required Maps SDKs).
   - Your Android SHA‑1 and/or iOS bundle identifier.
2. Open the maps config file (for example `lib/config/maps_config.dart`) and replace:
   - `YOUR_GOOGLE_MAPS_API_KEY` with your own key.
3. Rebuild the app.

Never commit a real unrestricted API key to a public repository.

### 5. Configure Firebase (Push Notifications)

This template uses Firebase Cloud Messaging (FCM) for push notifications.

High‑level steps:

1. Create a Firebase project.
2. Add Android and iOS apps (matching the package/bundle IDs you will use).
3. Download and add:
   - `google-services.json` to `book_user_app/android/app/`.
   - `GoogleService-Info.plist` to `book_user_app/ios/Runner/`.
4. Optionally run `flutterfire configure` to generate `firebase_options.dart` and wire it into `main.dart` (if not already).

Make sure the FCM server credentials in the backend are configured to match this project.

### 6. Change App Name, Package IDs, and Icons

1. **App name**:
   - Android: update `android/app/src/main/AndroidManifest.xml` and `android/app/src/main/res/values/strings.xml`.
   - iOS: update `Runner` target’s Display Name in Xcode.
2. **Package ID / Bundle identifier**:
   - Android: edit the `applicationId` in `android/app/build.gradle.kts`.
   - iOS: change the Bundle Identifier in Xcode.
3. **Icons and splash**:
   - Replace launcher icons and splash images as desired (you can use packages like `flutter_launcher_icons` if you prefer).

Documented examples and recommended tools for these changes are described in `04-Customization-Guide.md`.

### 7. Run the App

With the backend running and the API base URL configured:

```bash
cd book_user_app
flutter run
```

Use `-d` to pick a specific device (emulator, simulator, or physical device).

### 8. Troubleshooting

- **Cannot connect to API**:
  - Verify the base URL in the config file matches where the backend is running.
  - For Android emulators, use `10.0.2.2` instead of `localhost`.
- **CORS error in web builds**:
  - Ensure the backend’s `FRONTEND_URL` includes your web origin (for Flutter web).
- **Google Maps not rendering**:
  - Check that your Maps key is correctly configured and restricted to the appropriate platforms.

See the other documentation files for feature‑level details and customization options.

