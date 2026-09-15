# Prokopa v0.1.0

## What is Prokopa

Prokopa: Habits and Jurnaling -- a private, offline-first personal habit tracker, journal, mood and sleep recorder, and progress reviewer for Android. No account required.

## Highlights

- Full offline habit lifecycle: create, complete, skip, pause, resume, archive, delete
- Journal with free and guided modes, mood check-in, and sleep tracking
- Progress dashboard with calendar, weekly/monthly reviews, and explainable insights

## What Changed

### Added

- Home screen quick actions for mood check-in and journal entry
- Current date display on Home screen
- Bottom navigation label aligned to PRD ("Home")

### Fixed

- Database migration tests updated for schema version 5
- Recovery timestamp now uses execution date for reproducible insight calculations
- Insight test assertion corrected to check action field for non-causal disclaimer
- Widget and onboarding tests updated for Home navigation label

### Changed

- Navigation label from "Today" to "Home" per PRD section 8.2
- TodayScreen accepts optional journalStore and wellbeingStore for quick actions

## Verified

- [x] `dart analyze lib` clean
- [x] `dart analyze test` clean
- [x] `flutter test` all 85 tests passing
- [x] `flutter build apk --release` succeeds (55.7MB)
- [x] No emoji in repository
- [x] No cloud dependencies
- [x] No login/signup/account flow
- [x] Local-only data persistence (SQLite)
- [x] Export/import user-controlled
- [x] Privacy constraints satisfied

## Install

Download `app-release.apk` from the Assets section below and install on your Android device.

## Data

All data stays on your device. No account, no cloud sync, no internet required for core features.

## Known Limitations

- Sleep quick-access from Home screen deferred (available on Progress tab)
- Deep linking not implemented (optional per PRD)
- PRD.md contains legacy "HabitFlow" references in early sections (documentation only, no code impact)

## Build

```
flutter pub get
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`
