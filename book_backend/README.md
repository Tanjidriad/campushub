# CampusHub Pro - Backend API

Node.js/Express backend for the CampusHub Pro / book sale marketplace template. Built with Express, MongoDB, Socket.io, and Cloudinary.

## 🚀 Quick Start

See `Documentation/02-Installation-Backend.md` at the project root for a full, step‑by‑step installation guide.

### Prerequisites
- Node.js v18+
- MongoDB (local or Atlas)
- Cloudinary account
- SMTP service (Gmail, SendGrid, etc.)

### Installation (short version)

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your credentials
# Then start the server
npm run dev
```

## ⚙️ Environment Variables (overview)

See `.env.example` for a complete list and inline descriptions.

| Variable | Description |
|----------|-------------|
| `MONGODB_URI` | MongoDB connection string |
| `JWT_SECRET` | Secret for access tokens |
| `JWT_REFRESH_SECRET` | Secret for refresh tokens |
| `CLOUDINARY_*` | Cloudinary credentials |
| `SMTP_*` | Email service credentials |
| `GOOGLE_CLIENT_*` | Google OAuth credentials (optional) |
| `FRONTEND_URL` | Comma‑separated list of allowed web origins for CORS |
| `APP_URL` | Base app URL scheme used in deep links (password reset, etc.) |

## 📡 API Endpoints

### Authentication (`/api/auth`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new user |
| POST | `/login` | Login |
| GET | `/verify/:token` | Verify email |
| POST | `/forgot-password` | Request password reset |
| POST | `/reset-password/:token` | Reset password |
| POST | `/refresh-token` | Refresh access token |
| GET | `/me` | Get current user |
| PUT | `/profile` | Update profile |
| PUT | `/avatar` | Update avatar |

### Listings (`/api/listings`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all listings (with filters) |
| GET | `/:id` | Get single listing |
| POST | `/` | Create listing |
| PUT | `/:id` | Update listing |
| DELETE | `/:id` | Delete listing |
| PUT | `/:id/sold` | Mark as sold |
| POST | `/:id/wishlist` | Add to wishlist |
| GET | `/wishlist` | Get wishlist |

### Chat (`/api/chat`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/conversations` | Get conversations |
| POST | `/conversations` | Start conversation |
| GET | `/conversations/:id/messages` | Get messages |
| POST | `/conversations/:id/messages` | Send message |
| POST | `/block/:userId` | Block user |

### Admin (`/api/admin`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard` | Analytics |
| GET | `/users` | Get all users |
| PUT | `/users/:id/ban` | Ban/unban user |
| GET | `/listings/pending` | Pending listings |
| PUT | `/listings/:id/approve` | Approve listing |
| PUT | `/listings/:id/reject` | Reject listing |
| GET | `/reports` | View reports |

## 🔌 Socket.io Events

### Client → Server
| Event | Payload | Description |
|-------|---------|-------------|
| `conversation:join` | `{ conversationId }` | Join chat room |
| `message:send` | `{ conversationId, text, image? }` | Send message |
| `typing:start` | `{ conversationId }` | Start typing |
| `typing:stop` | `{ conversationId }` | Stop typing |
| `message:read` | `{ conversationId }` | Mark as read |

### Server → Client
| Event | Description |
|-------|-------------|
| `message:new` | New message received |
| `message:notification` | Push notification |
| `typing:update` | Typing status update |
| `message:read` | Read receipt |
| `user:online` / `user:offline` | Online status |

## 📁 Project Structure

```
├── server.js           # Entry point
├── config/             # Configuration
├── controllers/        # Route handlers
├── middleware/         # Express middleware
├── models/             # Mongoose schemas
├── routes/             # API routes
├── socket/             # Socket.io handlers
└── utils/              # Utility functions
```

## 🔒 Security Features

- JWT authentication with refresh tokens
- Password hashing with bcrypt (12 rounds)
- Rate limiting on API endpoints
- Helmet security headers
- XSS and injection protection
- Role-based access control

## 📦 Categories

- `books` - Textbooks & study materials
- `electronics` - Phones, laptops, gadgets
- `clothing` - Apparel & accessories
- `furniture` - Dorm & apartment items
- `services` - Tutoring, moving help, etc.
- `housing` - Sublets & roommates
- `vehicles` - Bikes, scooters, cars
- `other` - Everything else

## 📜 License

MIT License - Feel free to use for personal or commercial projects.
