## Backend Installation – `book_backend`

This document explains how to install, configure, and run the Node.js/Express backend API for local development and production.

### 1. Prerequisites

- **Node.js**: v18 or newer (LTS recommended).
- **npm**: comes with Node (v9+ recommended).
- **MongoDB**: local instance or MongoDB Atlas connection string.
- **Cloudinary account**: for image storage (free tier is sufficient for testing).
- **SMTP provider**: Gmail, SendGrid, Mailgun, etc. for transactional emails.
- **(Optional) Redis**: for caching and rate‑limiting enhancements.

### 2. Install Dependencies

```bash
cd book_backend
npm install
```

### 3. Configure Environment Variables

1. Copy the example file:

```bash
cp .env.example .env
```

2. Open `.env` in a text editor and fill in the values. At minimum you must set:

- Database:
  - `MONGODB_URI` – MongoDB connection string.
- JWT:
  - `JWT_SECRET` – secret used to sign access tokens.
  - `JWT_REFRESH_SECRET` – secret used to sign refresh tokens.
- Cloudinary:
  - `CLOUDINARY_CLOUD_NAME`
  - `CLOUDINARY_API_KEY`
  - `CLOUDINARY_API_SECRET`
- SMTP:
  - `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM_EMAIL`.

Additional optional variables are documented inline in `.env.example` (FRONTEND_URL, APP_URL, Redis, Google OAuth, Firebase Admin, etc.).

> **Important**: never commit your `.env` file or real credentials to version control or share them with other buyers.

### 4. Run the Server in Development

```bash
cd book_backend
npm run dev
```

By default the API listens on `http://localhost:5000` (or the `PORT` you set in `.env`).

- Health check: `http://localhost:5000/health`
- API info: `http://localhost:5000/api`

If required environment variables are missing, the server will log an error and exit.

### 5. Connecting the Mobile App

The Flutter app requires the **base API URL** (for example `http://10.0.2.2:5000` for Android emulator). You will configure this in the Flutter app’s environment/config file (see `03-Installation-Mobile-App.md`).

### 6. Docker / Production Deployment (Optional)

The backend includes a `Dockerfile` and `.env.docker` to help with containerized deployment.

Basic flow:

1. Ensure `.env` (or `.env.docker`) is configured with production credentials.
2. Build the image:

```bash
cd book_backend
docker build -t campushub-pro-api .
```

3. Run the container:

```bash
docker run -d \
  --name campushub-pro-api \
  -p 5000:5000 \
  --env-file .env \
  campushub-pro-api
```

Verify that `/health` and `/api` endpoints work from your host machine or hosting platform.

### 7. Common Issues

- **MongoDB connection error**:
  - Check `MONGODB_URI` value and that MongoDB is reachable.
- **Missing environment variables**:
  - The server will print which variables are missing on startup; update `.env` accordingly.
- **CORS errors**:
  - Ensure `FRONTEND_URL` includes your web frontend origin if you are using a web client.
  - Mobile apps (no Origin header) are allowed by default.

For advanced configuration (Redis, Firebase Admin, Google OAuth, admin endpoints), see the inline comments in `.env.example` and the other documentation files.

