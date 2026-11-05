# HealthMate

**Find Your Balance.** HealthMate is a simple, private health tracker built with Flutter. Log your daily steps, calories burned and water intake, track progress against your goals, and spot trends over time. All data stays on your device.

## Features

- **Dashboard**: today's steps (green), calories (red) and water (blue) with goal progress, a last-7-days steps chart and recent records.
- **Health records (CRUD)**: add, view, edit and delete daily records. One record per date.
- **Validation**: dates must be real and not in the future; steps, calories and water must be whole numbers within allowed limits.
- **Search, date filter and sorting**: search by date, filter by date range, sort by date, steps, calories or water.
- **Daily summary**: 7-day and 30-day averages, best day and change versus the previous period.
- **Settings**: your name, light/dark/system theme and editable daily goals (saved with `shared_preferences`).
- **Onboarding**: animated splash screen and a short welcome flow on first launch.
- **About / Help** screen.

## Tech stack

| Area | Choice |
| --- | --- |
| Framework | Flutter (Dart `^3.8.1`) |
| State management | `provider` (`ChangeNotifier`) |
| Local database | `sqflite` (SQLite) |
| Preferences | `shared_preferences` |
| Date formatting | `intl` |
| App icon | `flutter_launcher_icons` |

## Project structure

```
lib/
  main.dart              App entry, providers, splash/welcome routing, bottom navigation
  core/                  theme.dart, validators.dart, stats.dart
  data/                  database_helper.dart, health_repository.dart (all SQL lives here)
  models/                health_record.dart
  state/                 records_provider.dart, settings_provider.dart
  screens/               dashboard, records, record form, summary, settings, about, splash, welcome
                         widgets.dart (shared UI components)
```

The UI only talks to the providers, and the providers only talk to `HealthRepository`.

## Data and validation rules

- Records are stored in a local SQLite database. Nothing is sent anywhere.
- Date format is `yyyy-MM-dd`, one record per date.
- Limits: steps 0 - 100,000, calories 0 - 20,000 kcal, water 0 - 10,000 ml.
- Default goals: 10,000 steps, 500 kcal, 2,500 ml (editable in Settings).
- Goals are customisable targets, not medical advice.

## Getting started

Requirements: Flutter SDK (Dart 3.8.1 or newer), Android Studio or VS Code, and an Android emulator or device.

```bash
flutter pub get
flutter run
```

If you add a new provider in `main.dart`, use **hot restart** (not hot reload).

## Build notes

### App icon

The launcher icon source is `assets/icon/healthmate_icon.png` (square PNG, 1024x1024 recommended, with transparent padding for the adaptive icon). After changing it, regenerate the icons:

```bash
dart run flutter_launcher_icons
```

### Build a release APK

```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Install on a connected device:

```bash
flutter install
```

Or copy the APK to a phone and open it (allow "install unknown apps" if asked).

> The release build uses the default debug signing config, which is fine for testing and coursework. For a store release, create a keystore and configure signing in `android/app/build.gradle`.

### Troubleshooting

- **`ProviderNotFoundException` after editing `main.dart`**: stop the app and run it again (hot restart).
- **Icon did not change**: run `dart run flutter_launcher_icons`, then do a full rebuild (hot reload does not update icons). Uninstall the old app if the old icon is cached.
- **`flutter_launcher_icons` cannot find the image**: check that the paths in `pubspec.yaml` match the real file names in `assets/icon/`.

## Disclaimer

HealthMate is for personal tracking only and does not provide medical advice.