# Repository Guidelines

## Project Structure & Module Organization
This repository contains three applications:

- `backend/`: Express API and Socket.IO server. Main code lives in `backend/src`, organized into `controllers`, `routes`, `models`, `middleware`, `lib`, and `__tests__`.
- `frontend/`: React 19 + Vite web client. Source files are under `frontend/src` with `components`, `pages`, `store`, `lib`, `constants`, `assets`, and `__tests__`.
- `flutter/`: Flutter client. App code is in `flutter/lib`, split into `core`, `features`, and `shared`. Tests live in `flutter/test`.

## Build, Test, and Development Commands
Run commands from the relevant app directory.

- `cd backend && npm run dev`: start the API with `nodemon`.
- `cd backend && npm test`: run Jest with coverage.
- `cd backend && npm start`: run the API without reloads.
- `cd frontend && npm run dev`: start the Vite dev server.
- `cd frontend && npm run build`: create a production bundle.
- `cd frontend && npm run lint`: run ESLint.
- `cd frontend && npm run test:coverage`: run Vitest coverage.
- `cd flutter && flutter pub get`: install Dart and Flutter packages.
- `cd flutter && flutter analyze`: run static analysis.
- `cd flutter && flutter test`: run unit and widget tests.

## Coding Style & Naming Conventions
Follow the existing file-level style instead of reformatting unrelated code. The web apps use ES modules and descriptive names such as `auth.controller.js`, `socketService.js`, and `FriendsPage.jsx`. React components and pages use PascalCase; utilities, stores, and services use camelCase. Flutter files use `snake_case.dart`, while classes remain PascalCase. Run `frontend` linting before opening a PR; Flutter uses `flutter_lints`.

## Testing Guidelines
Place backend and frontend tests under each app’s `src/__tests__` tree using `*.test.js` or `*.test.jsx`. Mirror the runtime area when possible, for example `controllers/auth.controller.test.js` or `pages/LoginPage.test.jsx`. Flutter tests belong in `flutter/test` and use the `_test.dart` suffix. Prefer focused tests for controllers, stores, providers, and repositories.

## Commit & Pull Request Guidelines
Recent commits use short, imperative summaries such as `Add new UI sent friend requests` and `Security Fixes...`. Keep the first line concise and specific. PRs should include a summary, affected app (`backend`, `frontend`, or `flutter`), test evidence, linked issues, and screenshots for UI changes.

## Security & Configuration Tips
Do not commit real secrets. Use `backend/.env.example` as the template for local backend setup, and keep environment-specific values in local `.env` files. Any change touching auth, JWT handling, uploads, notifications, or privacy-policy enforcement should include tests or explicit verification notes.
