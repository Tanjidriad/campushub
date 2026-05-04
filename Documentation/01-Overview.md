## CampusHub Pro / Book Sale Template – Overview

This package contains a complete student marketplace template intended for resale on CodeCanyon. It is composed of:

- **Mobile app**: `book_user_app` – Flutter application for students to browse, list, and chat about items.
- **Backend API**: `book_backend` – Node.js/Express REST API with MongoDB, Socket.io, Cloudinary, and email.
- **(Optional) Web/admin app**: `Book_sale_web_admin_app` – web admin interface (if included in your purchase).

### Main Features

- **User authentication**: email/password sign up, login, email verification, password reset, profile + avatar.
- **Listings marketplace**: categories, filters, search, nearby listings, wishlist, promotions/featured listings.
- **Real‑time chat**: conversation list, message threads, typing indicators, read receipts, image & location sharing.
- **Reviews and reports**: rate users/sellers, report inappropriate content or behavior.
- **Push notifications**: via Firebase Cloud Messaging (FCM) for new messages and important events.
- **Admin endpoints**: moderation tools for users, listings, and reports (API level, optional admin UI).

### High‑Level Architecture

- **Flutter app (`book_user_app`)**
  - Feature‑based folder structure (`features/auth`, `features/listings`, `features/chat`, etc.).
  - State management via `flutter_bloc`.
  - Networking via `dio` with centralized `ApiClient` and auth interceptor.
  - Real‑time updates via `socket_io_client` and FCM.

- **Backend API (`book_backend`)**
  - `Express` server with REST endpoints under `/api/*`.
  - MongoDB with Mongoose models for users, listings, conversations, messages, reviews, notifications, and more.
  - Socket.io server for chat and presence.
  - Cloudinary for image uploads.
  - SMTP provider (Gmail/SendGrid/etc.) for transactional emails.

### Supported Versions (recommended)

- **Flutter SDK**: 3.10.x or newer.
- **Dart**: 3.10.x (see `pubspec.yaml`).
- **Node.js**: 18.x or newer (see `book_backend/package.json` engines).
- **MongoDB**: 5.x or newer (local or Atlas).

Refer to the other documents in the `Documentation/` folder for installation, configuration, customization, and API details.

