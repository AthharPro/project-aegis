# Offline-First Disaster Response App

A Flutter app designed for field responders in disaster zones with unstable connectivity.

## Features
- **Offline-First Data Entry**: Create incident reports without internet. Saved locally using Hive.
- **Robust Sync**: Automatically syncs pending reports to Supabase when connectivity returns.
- **Auth Persistence**: Session persists offline. No forced re-login.
- **Crisis UX**: High-contrast UI, large buttons, clear status indicators.

## Tech Stack
- **Flutter**: UI Framework
- **Hive**: Local NoSQL Database (Offline storage)
- **Supabase**: Authentication & Remote Database
- **Provider / GetIt**: DI & State Management (simplified)

## Setup
1. Copy `.env.example` to `.env` (or use provided keys).
2. Run `flutter pub get`.
3. Generate Hive adapters: `dart run build_runner build`.
4. Run app: `flutter run`.

## Offline & Sync Flow
1. **Offline**: User submits report -> Saved to Hive (`synced: false`). Banner shows "Offline".
2. **Network Restore**: App listens to connectivity.
3. **Sync**: `SyncService` wakes up -> Pushes pending items to Supabase -> Marks `synced: true` in Hive.

## Folder Structure
- `lib/core`: Constants, Theme, Network Utils
- `lib/data`:
    - `local`: HiveService
    - `remote`: SupabaseService
    - `models`: IncidentModel
    - `sync_service.dart`: Sync logic
- `lib/presentation`: Screens and Widgets
