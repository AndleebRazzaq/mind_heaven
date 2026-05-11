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
- `Main Shell` tabs/screens include Journal, Insights, Learn CBT, and Profile.

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
- Injects providers into `AppRoot` using the `provider` package.

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
- Reads onboarding completion and auth session.
- Returns target route (`onboarding`, `welcome`, `shell`).

## 4) Onboarding State

Core files:

- `lib/features/onboarding/data/repositories/onboarding_state_repository_impl.dart`
- `lib/screens/onboarding_screen.dart`

Implementation:

- Uses `SharedPreferences` key: `onboarding_seen`
- In debug mode, this is reset in `bootstrap.dart`.

## 5) Firebase Integration

Core files:

- `android/app/google-services.json`
- `lib/firebase_options.dart`
- `lib/services/firebase_runtime.dart`

Current implementation:

- Firebase is initialized using `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- Used for Authentication and Firestore storage of journal entries.

## 6) API Integration (Backend)

Core files:

- `lib/core/network/api_client.dart`
- `backend/app/main.py`
- `backend/app/utils.py`

How it works:

- Backend runs FastAPI on port **8001**.
- Mobile app calls backend through the configured base URL in `ApiClient`.
- For Android Emulator, `10.0.2.2:8001` is typically used.

Run commands (Windows PowerShell):

1.  **Backend:** `uvicorn app.main:app --reload --host 0.0.0.0 --port 8001`
2.  **Frontend:** `flutter run`

## 7) Main Feature Modules

Primary screens:

- `lib/screens/journal_screen.dart`: Entry point for journaling.
- `lib/screens/reframe_output_screen.dart`: Displays AI analysis and reframes.
- `lib/screens/analytics_screen.dart`: Visualizes mood trends.
- `lib/screens/learn_cbt_screen.dart`: Educational content.
- `lib/screens/profile_screen.dart`: User settings.

Supporting layers:

- Models: `lib/models/*`
- Providers: `lib/presentation/providers/*` (using `ChangeNotifier`)
- Repositories: `lib/data/repositories/*`

## 8) Notes and Recommended Next Steps

1.  **Backend Deployment:** When deploying to production, update the `API_BASE_URL` in the app's configuration.
2.  **Ollama Dependency:** The local LLM (Ollama) must be running for the analysis to work in remote mode.
3.  **Local vs Remote:** The `JournalRepositoryImpl` can be toggled to use local mock analysis or the remote FastAPI backend.
