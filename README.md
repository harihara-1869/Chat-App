# Real-Time Chat Application

A full-stack real-time chat application built with the MERN stack (MongoDB, Express, React, Node.js) and Socket.io. Features secure authentication, real-time messaging, image sharing, friend system, and a modern responsive UI.

## 🚀 Project Information

### Tech Stack
- **Frontend:** React 19, Vite, Zustand (State Management), TailwindCSS, DaisyUI
- **Backend:** Node.js, Express.js, Socket.io
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens), bcryptjs
- **Media Storage:** Cloudinary
- **Testing:** Jest (Backend), Vitest (Frontend)

### Key Features
- 🔐 **Secure Authentication:** User signup, login, google oauth and logout with HttpOnly cookies.
- 👥 **Friend System:** Search users, send friend requests, and manage friends.
- 💬 **Real-time Messaging:** Chat only with friends using Socket.io.
- 🔔 **Notifications:** Real-time browser notifications for new messages.
- 🟢 **Online Status:** Real-time online/offline user status updates.
- 🖼️ **Image Sharing:** Upload and share images in chat via Cloudinary.
- 🎨 **Theming:** Multiple color themes support (coffee, dark, etc.).
- 📜 **Policy Enforcement:** Mandatory acceptance of Privacy Policy and Terms & Conditions.
- 🛡️ **Enhanced Security:** Rate limiting, regex protection, and payload limits.
- 📱 **Responsive Design:** Mobile-friendly interface.

---

## 🔗 Endpoints

### Backend API (`http://localhost:5001`)

#### Authentication (`/api/auth`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `POST` | `/signup` | Create a new user account | No |
| `POST` | `/login` | Log in and receive auth cookie | No |
| `POST` | `/logout` | Log out and clear session | No |
| `POST` | `/verify-email` | Verify user email address | No |
| `POST` | `/reset-password` | Reset password via email token | No |
| `POST` | `/update-password` | Update password | **Yes** |
| `GET` | `/google` | Initiate Google OAuth login | No |
| `GET` | `/google/callback` | Handle Google OAuth callback | No |
| `GET` | `/google/verify-token` | Verify Google token | No |
| `POST` | `/google/complete-signup` | Complete (Google) OAuth signup | No |
| `POST` | `/google/accept-policies` | Accept policies (Google/Existing) | No |

#### User (`/api/user`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `PUT` | `/update-profile` | Update profile picture | **Yes** |
| `GET` | `/get-user` | Get current authenticated user info | **Yes** |
| `GET` | `/get-friends` | Get list of friends | **Yes** |

#### Friends (`/api/friend`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `POST` | `/request/:userId` | Send friend request | **Yes** |
| `GET` | `/requests/pending` | Get received pending requests | **Yes** |
| `POST` | `/accept/:requestId` | Accept friend request | **Yes** |
| `POST` | `/reject/:requestId` | Reject friend request | **Yes** |

#### Search (`/api/search`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `GET` | `/?q={query}` | Search users by name or email | **Yes** |

#### Messages (`/api/message`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `GET` | `/:id` | Get message history (Friends only) | **Yes** |
| `POST` | `/send/:id` | Send message/image (Friends only) | **Yes** |

### Frontend Routes
| Path | Component | Description |
| :--- | :--- | :--- |
| `/` | `HomePage` | Main chat interface (Protected) |
| `/friends` | `FriendsPage` | Find users and manage requests |
| `/signup` | `SignUpPage` | User registration |
| `/login` | `LoginPage` | User login |
| `/settings` | `SettingsPage` | Theme selection settings |
| `/profile` | `ProfilePage` | View/Edit user profile |

---

## 🛡️ Security System

The application implements robust security best practices:

1.  **JWT Authentication:** HttpOnly cookies to prevent XSS.
2.  **Rate Limiting:** Applied to all API routes to prevent abuse/brute-force.
3.  **Regex Protection:** User input escaped in search queries to prevent ReDoS.
4.  **Friend-Only Messaging:** Middleware (`isFriend`) restricts chat access.
5.  **Payload Limits:** JSON body limit (10MB) to prevent large payload attacks.
6.  **CORS Policy:** Strict origin restriction to `FRONTEND_URL`.
7.  **Data Sanitization:** Inputs validated and sanitized.

---

## 🏁 Get Started

### Prerequisites
- Node.js (v18 or higher)
- MongoDB (Local or Atlas)
- Cloudinary Account (for image uploads)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/harihara-1869/Chat-App.git
    cd "Chat-App"
    ```

2.  **Backend Setup**
    ```bash
    cd backend
    npm install
    ```
    - Create a `.env` file in the `backend` directory based on `.env.example`:
      ```env
      PORT=5001
      MONGO_URI=your_mongodb_connection_string
      JWT_SECRET=your_secret_key
      FRONTEND_URL=http://localhost:5173
      NODE_ENV=development
      CLOUDINARY_CLOUD_NAME=your_cloud_name
      CLOUDINARY_API_KEY=your_api_key
      CLOUDINARY_API_SECRET=your_api_secret
      GOOGLE_CLIENT_ID=your_google_client_id
      GOOGLE_CLIENT_SECRET=your_google_client_secret
      ```
    - Start the server:
      ```bash
      npm run dev
      ```

3.  **Frontend Setup**
    ```bash
    cd frontend
    npm install
    # Start the frontend
    npm run dev
    ```

4.  **Access the App**
    Open `http://localhost:5173` in your browser.

---

## 🧪 Testing Procedures

The project includes comprehensive test suites for both backend and frontend.

### Backend Tests (Jest)
Tests cover controllers, middleware, and utility functions.
```bash
cd backend
npm test
```

### Frontend Tests (Vitest)
Tests cover stores, pages, components, and utilities using React Testing Library.
```bash
cd frontend
npm test
```

### Running All Tests
To ensure system stability, run both suites before pushing major changes.
