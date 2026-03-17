# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A full-stack real-time chat application built with the MERN stack (MongoDB, Express, React, Node.js) and Socket.io. Features secure JWT/Google OAuth authentication, end-to-end encryption (Signal Protocol), real-time messaging, friend system, and image sharing.

## Commands

### Backend (port 5001)
```bash
cd backend
npm run dev      # Start development server with nodemon
npm test         # Run Jest tests with coverage
npm test:watch   # Run Jest tests in watch mode
npm start        # Start production server
```

### Frontend (port 5173)
```bash
cd frontend
npm run dev          # Start Vite development server
npm run build        # Build for production
npm run lint         # Run ESLint
npm run preview      # Preview production build
npm test             # Run Vitest
npm run test:ui      # Run Vitest with browser UI
npm run test:coverage # Run Vitest with coverage
```

## Architecture

### Backend (`backend/src/`)
- **Routes**: `auth.route.js`, `friend.route.js`, `message.route.js`, `search.route.js`, `user.route.js`, `device.route.js`, `keys.route.js`, `privacy.route.js`
- **Controllers**: Handle business logic for auth, friends, messages, user, device, and key operations
- **Models**: MongoDB schemas (user, message, conversation, friendRequest, device, signedPreKey, oneTimePreKey, session)
- **Middleware**: `auth.middleware.js` (JWT verification), `isFriend.middleware.js` (friend-only chat), `rateLimit.middleware.js` (abuse prevention), `privacy.middleware.js` (policy acceptance)
- **Lib**: Database connection (`db.js`), Socket.io (`socket.js`), Cloudinary (`cloudinary.js`), Passport (`passport.js`), Mailgun (`mailgun.js`), utilities (`utils.js`)

### Frontend (`frontend/src/`)
- **Pages**: HomePage, FriendsPage, LoginPage, SignUpPage, SettingsPage, ProfilePage, and policy pages
- **Components**: ChatContainer, ChatHeader, MessageInput, Navbar, Sidebar, skeletons
- **Stores** (Zustand): `useAuthStore`, `useChatStore`, `useFriendStore`, `useNotificationStore`, `useThemeStore`
- **Lib**: Axios instance (`axios.js`), Socket service (`socketService.js`)

## API Endpoints (Backend)

| Route | Description |
|-------|-------------|
| `/api/auth` | Signup, login, logout, Google OAuth, email verification, password reset |
| `/api/user` | Profile management, get user info, get friends |
| `/api/friend` | Send/accept/reject friend requests |
| `/api/search` | User search by name or email |
| `/api/message` | Get message history, send encrypted messages/images (friends only) |
| `/api/device` | Register/remove device, get own device info |
| `/api/keys` | Upload signed pre-key, one-time pre-key, get pre-key bundle |

## Key Patterns

- **Authentication**: JWT stored in HttpOnly cookies, protected routes use `auth.middleware.js`
- **Real-time**: Socket.io handles online status, typing indicators, and message delivery
- **Friend-only messaging**: `isFriend.middleware.js` ensures only friends can exchange messages
- **State management**: Zustand stores sync with backend via Socket.io and REST API
- **Image uploads**: Sent to Cloudinary, URL stored in message
- **E2EE (Signal Protocol)**: Messages encrypted client-side using libsignal-client. First message uses prekey bundle, subsequent messages use Double Ratchet. Backend stores encrypted ciphertext only - never sees plaintext.

## Security

- Rate limiting on all `/api` routes
- JSON payload limit (10MB)
- CORS restricted to `FRONTEND_URL`
- Security headers (X-Content-Type-Options, X-Frame-Options, CSP)
- Regex-protected search queries to prevent ReDoS

## Environment Variables

### Backend (`.env`)
```
PORT=5001
MONGO_URI=<mongodb_connection_string>
JWT_SECRET=<secret_key>
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
CLOUDINARY_CLOUD_NAME=<cloud_name>
CLOUDINARY_API_KEY=<api_key>
CLOUDINARY_API_SECRET=<api_secret>
GOOGLE_CLIENT_ID=<client_id>
GOOGLE_CLIENT_SECRET=<client_secret>
```

### Frontend (`.env`)
```
VITE_API_URL=http://localhost:5001/api
VITE_WS_URL=http://localhost:5001
```