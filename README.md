# HealthMate

Personal Health and Wellness Tracker. CI6330 Mobile Application Development coursework.

Record daily steps, calories burned and water intake, review and filter past records by date,
and see today's summary on a dashboard. Data is stored locally with SQLite (`sqflite`).

## Tech
- Flutter 3.47.9 / Dart 3.13.7
- `sqflite` for local storage, `provider` for state management (MVVM, feature-based structure)

## Run
```
flutter pub get
flutter run
```

## Build release APK
```
flutter build apk --release
```
