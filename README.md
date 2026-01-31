# Real-Time Chat Application

A full-stack real-time chat application built with the MERN stack (MongoDB, Express, React, Node.js) and Socket.io. Features secure authentication, real-time messaging, image sharing, and a modern responsive UI.

## 🚀 Project Information

### Tech Stack
- **Frontend:** React 19, Vite, Zustand (State Management), TailwindCSS, DaisyUI
- **Backend:** Node.js, Express.js, Socket.io
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens), bcryptjs
- **Media Storage:** Cloudinary
- **Testing:** Jest (Backend), Vitest (Frontend)

### Key Features
- 🔐 **Secure Authentication:** User signup, login, and logout with HttpOnly cookies.
- 💬 **Real-time Messaging:** Instant message delivery using Socket.io.
- 🟢 **Online Status:** Real-time online/offline user status updates.
- 🖼️ **Image Sharing:** Upload and share images in chat via Cloudinary.
- 🎨 **Theming:** Multiple color themes support (coffee, dark, etc.).
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
| `PUT` | `/update-profile` | Update profile picture | **Yes** |
| `GET` | `/get-user` | Get current authenticated user info | **Yes** |

#### Messages (`/api/message`)
| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :--- |
| `GET` | `/users` | Get list of users for sidebar (excluding self) | **Yes** |
| `GET` | `/:id` | Get message history with a specific user | **Yes** |
| `POST` | `/send/:id` | Send a message/image to a user | **Yes** |

### Frontend Routes
| Path | Component | Description |
| :--- | :--- | :--- |
| `/` | `HomePage` | Main chat interface (Protected) |
| `/signup` | `SignUpPage` | User registration |
| `/login` | `LoginPage` | User login |
| `/settings` | `SettingsPage` | Theme selection settings |
| `/profile` | `ProfilePage` | View/Edit user profile |

---

## 🛡️ Security System

The application implements several security best practices:

1.  **JWT Authentication:** Uses JSON Web Tokens stored in **HttpOnly cookies** to prevent XSS attacks (client-side script cannot access the token).
2.  **Password Hashing:** User passwords are hashed using `bcryptjs` before storage.
3.  **Protected Routes (Middleware):** Backend API endpoints are protected by `protectRoute` middleware that validates the JWT.
4.  **CORS Policy:** Configured to allow requests only from the trusted frontend origin (`FRONTEND_URL`).
5.  **Environment Variables:** Sensitive data (API keys, secrets) are stored in `.env` files and never committed to version control.

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
    cd "Chat App/mine"
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

> [!NOTE]
> If you encounter git push errors about "rejected" updates, it means the remote repo has changes you don't have. Run `git pull origin main --rebase` to sync before pushing.

---

## 🧪 Testing Procedures

The project includes comprehensive test suites for both backend and frontend.

### Backend Tests (Jest)
Tests cover controllers, middleware, and utility functions.
```bash
cd backend
npm test
```
*Current Status: 39 tests passing*

### Frontend Tests (Vitest)
Tests cover stores, pages, components, and utilities using React Testing Library.
```bash
cd frontend
npm test
```
*Current Status: 49 tests passing*

### Running All Tests
To ensure system stability, run both suites before pushing major changes.
