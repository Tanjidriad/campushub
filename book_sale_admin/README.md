# CampusHub Admin Panel

A Flutter admin dashboard for managing the CampusHub marketplace — a campus-oriented buy/sell platform with full user management, listing moderation, reports, and category configuration.

## Features

- **Dashboard** — Live stats: total users, listings, revenue, recent activity
- **User Management** — Search, filter by role/status, ban/unban users
- **Listing Moderation** — Approve/reject/feature/delete listings
- **Category Config** — Create/edit/delete categories with image upload, toggle active status, drag-to-reorder
- **Reports** — Tabbed view (pending/reviewed/resolved), review with actions (warn/ban/dismiss), CSV export
- **Settings** — Dark/light theme toggle, logout
- **CSV Export** — Export users and reports data to clipboard as CSV

## Architecture

Clean Architecture with BLoC state management:

```
lib/
├── core/              # ApiClient, theme, router, widgets, utils
│   ├── router/        # GoRouter config with StatefulShellRoute
│   ├── theme/         # AppColors, AppTextStyles, ThemeBloc
│   ├── utils/         # CSV export, helpers
│   └── widgets/       # AdminShellLayout, shared widgets
├── features/
│   ├── auth/          # Login, JWT auth with refresh tokens
│   ├── dashboard/     # Stats + activity feed
│   ├── listings/      # All + pending listings management
│   ├── category_config/ # Categories + education config
│   ├── reports/       # Report review system
│   └── users/         # User management (search, ban)
├── screens/           # Legacy screens (users_screen, settings_screen)
└── main.dart          # App entry point
```

Each feature follows: `data/` → `domain/` → `presentation/` with:
- **Entity** (domain model, Equatable)
- **Model** (JSON serialization, extends Entity)
- **Repository** (abstract interface + implementation)
- **Use Case** (single-responsibility, returns `Either<Failure, T>`)
- **BLoC** (events → state management)

## Prerequisites

- Flutter SDK ≥ 3.10.7
- A running CampusHub backend API (Node.js)
- Admin account credentials

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run (development — uses default backend URL)
flutter run

# 3. Run with custom backend URL
flutter run --dart-define=BASE_URL=https://your-server.com
```

## Environment Configuration

The app uses `--dart-define` for environment variables:

| Variable   | Default                                | Description      |
|------------|----------------------------------------|------------------|
| `BASE_URL` | `https://coolify.codingwithriad.me`    | Backend API URL  |

### Build for Production

```bash
# Web
flutter build web --dart-define=BASE_URL=https://api.yoursite.com

# Android
flutter build apk --dart-define=BASE_URL=https://api.yoursite.com

# iOS
flutter build ios --dart-define=BASE_URL=https://api.yoursite.com
```

## Navigation

Uses `go_router` with `StatefulShellRoute.indexedStack`:

| Route         | Screen      |
|---------------|-------------|
| `/dashboard`  | Dashboard   |
| `/users`      | Users       |
| `/listings`   | Listings    |
| `/categories` | Categories  |
| `/reports`    | Reports     |
| `/settings`   | Settings    |
| `/login`      | Login       |

Auth redirect: unauthenticated users are sent to `/login`; authenticated users on `/login` are redirected to `/dashboard`.

## Authentication

- JWT-based with access + refresh tokens
- Tokens stored in `FlutterSecureStorage` (encrypted on Android)
- Automatic token refresh on 401 with mutex lock (prevents concurrent refresh requests)
- Persistent login: saved user profile is restored on app launch

## Responsive Layout

- **Desktop** (≥1100px): Expandable sidebar with labels
- **Tablet** (600–1100px): Collapsed icon-only sidebar
- **Mobile** (<600px): Bottom navigation bar

## Theme

Light and dark themes with a complete design system:

- `AppColors` — Primary (#6C5CE7), semantic colors
- `AppTextStyles` — Typography scale (h1–caption)
- `AppSpacing` — 4/8/12/16/20/24/32/48px spacing tokens
- `AppRadius` — xs/sm/md/lg/xl border radius presets
- Theme persists across sessions via `FlutterSecureStorage`

## Key Packages

| Package                         | Purpose                    |
|---------------------------------|----------------------------|
| `flutter_bloc`                  | State management           |
| `go_router`                     | Declarative routing        |
| `dio`                           | HTTP client                |
| `flutter_secure_storage`        | Secure token storage       |
| `get_it` + `dartz`              | DI + functional Either     |
| `fl_chart`                      | Dashboard charts           |
| `cached_network_image`          | Image caching              |
| `image_picker`                  | Category image upload      |
| `flutter_screenutil`            | Responsive sizing          |
| `shimmer`                       | Loading skeletons          |
| `flutter_staggered_animations`  | List animations            |

## Web Compatibility

The app is fully web-compatible:
- No `dart:io` imports — image uploads use `Uint8List` bytes
- Cross-platform image picker via `image_picker`
- All API calls use `dio` (works on web)

## License

This is a commercial product. See the license file included with your purchase.
