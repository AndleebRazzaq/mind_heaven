# Mind Heaven - App Workflow and Implementation

This document explains how the app starts, how users move through screens, and how Firebase/API integration is implemented.

## 1) High-Level Flow

Runtime flow:

1. `main.dart` calls `bootstrap()`
2. `bootstrap()` initializes Firebase + app dependencies
3. App opens `Splash`
4. Splash decides route:
   - `Onboarding` (if first-time user)
   - `Welcome` (if onboarding done but not signed in)
   - `Main Shell` (if signed in)

Main user journey:

- `Splash` -> `Onboarding` -> `Welcome` -> `Auth` -> `Main Shell`
- `Main Shell` tabs/screens include Journal, Analytics, CBT Learn, and Profile.

## 2) Entry and Bootstrap

Core files:

- `lib/main.dart`
- `lib/app/bootstrap.dart`
- `lib/app/app.dart`

What `bootstrap()` does:

- Ensures Flutter binding is initialized
- Initializes Firebase via `FirebaseRuntime.ensureInitialized()`
- Creates services and repositories:
  - `AuthService`
  - `StorageService`
  - `FirestoreJournalService`
  - `AnalyticsService`
  - `ApiClient` + `JournalRemoteDataSource`
  - `JournalRepositoryImpl`
- Injects providers into `AppRoot`

Debug behavior currently enabled:

- In debug mode, `onboarding_seen` is reset to `false` each startup so onboarding always appears for UI testing.

## 3) Routing and Navigation

Core files:

- `lib/app/router.dart`
- `lib/routes/app_routes.dart`

Routes:

- `/` -> Splash
- `/onboarding` -> Onboarding
- `/welcome` -> Welcome
- `/auth/login` -> Auth (login)
- `/auth/signup` -> Auth (signup)
- `/shell` -> Main shell

Splash decision logic:

- `lib/features/splash/presentation/splash_controller.dart`
- Reads onboarding completion from `OnboardingStateRepository`
- Reads auth session from `SessionRepository`
- Returns target route (`onboarding`, `welcome`, `shell`)

## 4) Onboarding State

Core files:

- `lib/features/onboarding/data/repositories/onboarding_state_repository_impl.dart`
- `lib/features/onboarding/presentation/onboarding_controller.dart`

Implementation:

- Uses `SharedPreferences` key: `onboarding_seen`
- `isCompleted()` checks this key
- `markCompleted()` sets it `true`

## 5) Firebase Integration

Core files:

- `android/app/google-services.json`
- `lib/firebase_options.dart`
- `lib/services/firebase_runtime.dart`

Current implementation:

- Firebase is initialized using `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- Android values are configured from current Firebase project data
- iOS section exists in `firebase_options.dart` but needs real iOS `appId` from `GoogleService-Info.plist` if iOS is used

Already present in dependencies:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`

## 6) API Integration (Backend)

Core files:

- `lib/core/network/api_client.dart`
- `backend/run_backend.ps1`
- `scripts/run_android_with_api.ps1`

How it works:

- Backend runs FastAPI on port `8001`
- Android script applies:
  - `adb reverse tcp:8001 tcp:8001`
- Mobile app can call backend through `127.0.0.1:8001` on the device

Run commands (Windows PowerShell):

1. `powershell -ExecutionPolicy Bypass -File "D:/fyp/mind_heaven/backend/run_backend.ps1"`
2. `powershell -ExecutionPolicy Bypass -File "D:/fyp/mind_heaven/scripts/run_android_with_api.ps1" -d <DEVICE_ID>`

## 7) Main Feature Modules

Primary screens:

- `lib/screens/journal_screen.dart`
- `lib/screens/analytics_screen.dart`
- `lib/screens/learn_cbt_screen.dart`
- `lib/screens/profile_screen.dart`

Supporting layers:

- Models: `lib/models/*`
- Providers: `lib/presentation/providers/*`
- Domain/Data repositories in `lib/domain`, `lib/data`, and `lib/features/*`

## 8) Notes and Recommended Next Steps

1. If onboarding should not reset every debug run, remove the debug reset block in `bootstrap.dart`.
2. Add real iOS Firebase config (`GoogleService-Info.plist` + iOS app id in `firebase_options.dart`).
3. If notifications are required, add FCM setup and runtime permission handling.
4. Keep route constants in `lib/routes/app_routes.dart` as the single source of navigation names.
