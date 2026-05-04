## API Reference (High Level)

This document summarizes the main REST API endpoints exposed by `book_backend`. All paths are relative to the base URL plus `/api`.

### Authentication – `/api/auth`

- `POST /register` – register new user.
- `POST /login` – log in and receive access + refresh tokens.
- `GET /verify/:token` – verify email via token.
- `POST /forgot-password` – send password reset email.
- `POST /reset-password/:token` – reset password using token.
- `POST /refresh-token` – exchange refresh token for new access token.
- `GET /me` – return current authenticated user.
- `PUT /profile` – update profile fields.
- `PUT /avatar` – upload/update avatar (multipart).
- `PUT /password` – change password.
- `POST /resend-verification` – resend email verification.
- `POST /logout` – invalidate refresh token (where implemented).

### Listings – `/api/listings`

- `GET /` – list all listings with filters and pagination.
- `GET /highlights` – featured listings.
- `GET /nearby` – listings near a location.
- `GET /user/:userId` – listings for a specific user.
- `GET /my-listings` – listings for the current user.
- `GET /:id` – single listing detail.
- `GET /:id/similar` – similar listings.
- `POST /` – create listing (multipart with images).
- `PUT /:id` – update listing.
- `DELETE /:id` – delete listing.
- `DELETE /:id/images/:imageId` – delete single image from a listing.
- `PUT /:id/sold` – mark listing as sold.
- `POST /:id/wishlist` – add to wishlist.
- `DELETE /:id/wishlist` – remove from wishlist.
- `GET /wishlist` – get wishlist for current user.
- `POST /:id/promote` – promote listing (featured).

### Chat – `/api/chat`

- `GET /conversations` – list conversations for current user.
- `POST /conversations` – start a new conversation.
- `GET /conversations/:id/messages` – fetch paginated messages.
- `POST /conversations/:id/messages` – send text/image/location message.
- `POST /block/:userId` – block another user.

Related Socket.io events are described in `book_backend/README.md`.

### Users – `/api/users`

- `GET /me` – alias for current user details (where implemented).
- `GET /:id` – public user profile (if exposed).
- Other management endpoints may exist depending on your version.

### Reviews – `/api/reviews`

- Endpoints for creating and fetching reviews of users/sellers.

### Reports – `/api/reports`

- Endpoints for reporting users/listings and for admin moderation.

### Notifications – `/api/notifications`

- Fetch in‑app notifications and mark them as read.

### Admin – `/api/admin`

- Endpoints for:
  - Viewing dashboard metrics.
  - Managing users (ban/unban).
  - Moderating listings (approve/reject).
  - Handling reports.

For exact request/response payloads and advanced endpoints, import the included Postman collection (see `06-Postman-Usage.md`) or examine controller code in `book_backend/controllers/`.

