# Mind Heaven - Demo One Pager

## Project Purpose

Mind Heaven is a Flutter mobile app for mental well-being support.  
It helps users journal thoughts, detect emotional/cognitive patterns, and view progress analytics, with Firebase authentication and a FastAPI backend for AI-assisted analysis.

## Tech Stack

- **Frontend:** Flutter (Dart)
- **State Management:** Provider
- **Backend API:** FastAPI (Python)
- **Authentication:** Firebase Auth
- **Cloud Data:** Cloud Firestore
- **Local Data:** SharedPreferences

## Core User Flow

1. **Splash**
   - App starts and checks onboarding + auth state.
2. **Onboarding**
   - First-time guidance screens.
3. **Welcome/Auth**
   - User logs in, signs up, Google sign-in, or anonymous flow.
4. **Main App (Shell)**
   - Journal
   - Analytics
   - Learn CBT
   - Profile

## Architecture Summary

- `main.dart` -> `bootstrap()` initializes dependencies.
- `AppRouter` handles route navigation.
- `SplashController` decides initial screen.
- Repositories/services split domain logic from UI.
- Providers expose state to UI.

## Firebase Setup (Current)

- Android configured with `android/app/google-services.json`.
- Firebase initialized using `lib/firebase_options.dart`.
- Used packages:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`

## API Integration (Android Device)

To run app with backend integration:

1. Start backend:
   - `powershell -ExecutionPolicy Bypass -File "D:/fyp/mind_heaven/backend/run_backend.ps1"`
2. Start Flutter + adb reverse:
   - `powershell -ExecutionPolicy Bypass -File "D:/fyp/mind_heaven/scripts/run_android_with_api.ps1" -d <DEVICE_ID>`

`adb reverse` maps device `127.0.0.1:8001` to PC backend `:8001`.

## Key Features for Demo

- Splash -> onboarding -> auth routing logic
- Journal entry and thought capture
- Backend-assisted analysis call
- Analytics charts and trends
- Profile and sign-out flow

## Quick Test Checklist

- [ ] App launches to splash
- [ ] Onboarding appears (debug mode reset currently enabled)
- [ ] Login/signup works with Firebase
- [ ] Journal submit triggers backend response
- [ ] Analytics screen loads trends
- [ ] App runs with backend on real Android device

## Notes

- Debug build currently forces onboarding to show on each launch.
- For iOS deployment, ensure valid `GoogleService-Info.plist` and matching iOS Firebase app id.
