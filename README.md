# HealthMate

Personal Health and Wellness Tracker. CI6330 Mobile Application Development coursework.

Record daily steps, calories burned and water intake, review and search past records by date,
and see today's progress on a dashboard. All data is stored on the device with SQLite (`sqflite`).

## Features
- **Dashboard** – today's totals for steps, calories and water, progress rings towards daily goals,
  and a last-7-days bar chart
- **Health records** – list of all records (newest first), search by a single date or a date range
- **Add / edit / delete** – validated form (numbers only, sensible limits, no future dates);
  delete by swiping or from the edit screen, always with confirmation
- **Daily goals** – editable targets used by the dashboard
- Demo data (two weeks) is created on first launch
- Light and dark theme, large-text support, adaptive layout (bottom bar on phones,
  navigation rail on landscape/tablets)

## Architecture
MVVM with a feature-based folder structure and Provider for state management.

```
lib/
├─ main.dart, app.dart          # dependency wiring, theme, navigation shell
├─ core/                        # shared: database helper, theme, formatters, validators, widgets
└─ features/
   ├─ health_records/           # data (model, repository) · viewmodel · view
   ├─ dashboard/                # view (summary + weekly chart)
   └─ goals/                    # data · viewmodel · view
```
View → ViewModel (`ChangeNotifier`) → Repository → `DatabaseHelper` → SQLite.

## Database
`health_records(id INTEGER PK, date TEXT, steps INTEGER, calories INTEGER, water INTEGER)`
plus `daily_goals` (single row) added in schema version 2 via `onUpgrade`.

## Tech
- Flutter 3.47.9 / Dart 3.13.7
- `sqflite`, `path`, `provider`, `intl`, `fl_chart`
- Tests: `flutter_test`, `sqflite_common_ffi` (real SQLite in unit tests)

## Run
```
flutter pub get
flutter run
```

## Test
```
flutter test
```

## Build release APK
```
flutter build apk --release
```
Release builds are signed with the key described in `android/key.properties`
(not committed). Without that file, release builds fall back to the debug key.
