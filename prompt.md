# Prompt: Backend Only – Node.js + MongoDB + Socket.io + Cloudinary for “CampusHub Pro”

You are an expert Node.js backend engineer.  
Your task is to **design and implement the complete backend** for the CampusHub Pro student marketplace app using:

- **Node.js + Express** for REST APIs  
- **MongoDB + Mongoose** for database  
- **Socket.io** for real-time chat  
- **Cloudinary** for image storage  
- **JWT** for auth  

This backend will power a Flutter mobile app and a web admin panel and must be clean enough to sell as a CodeCanyon product.[web:119][web:120]

---

## 1. Backend Overview

### 1.1 What this backend must handle

- User registration/login (students + admins)  
- JWT authentication and role-based access (student/admin)  
- Listings CRUD (buy/sell posts)  
- Image upload to Cloudinary and URL storage in MongoDB  
- Real-time one-to-one chat between buyer and seller over Socket.io  
- Admin moderation (approve, hide, or delete listings; manage users)  

### 1.2 High-level architecture

- `Express` app handles HTTP requests (`/api/auth`, `/api/listings`, `/api/admin`, etc.).[web:119]  
- `MongoDB` stores Users, Listings, and ChatMessages.  
- `Socket.io` runs on top of the same HTTP server for real-time chat events.[web:122][web:125]  
- `Cloudinary` handles all media uploads; backend only stores URLs returned by Cloudinary.[web:124][web:132]  

---

## 2. Project Structure (Backend Folder)

Inside the main repo, the `backend/` folder looks like:

```bash
backend/
├── server.js
├── routes/
│   ├── auth.js
│   ├── listings.js
│   ├── chat.js
│   └── admin.js
├── models/
│   ├── User.js
│   ├── Listing.js
│   └── ChatMessage.js
├── middleware/
│   ├── auth.js
│   ├── errorHandler.js
│   └── upload.js
├── config/
│   ├── db.js
│   └── cloudinary.js
├── .env.example
├── package.json
└── README_BACKEND.md
