# Store Tracker MVP

Local-first Flutter inventory, sales, expense, and profit tracker for small shops.

## Run

- `flutter pub get`
- `flutter run`
- Demo data is opt-in: `flutter run --dart-define=DEMO_MODE=true`
- Release builds must use a configured Firebase project, signing keys, notification permissions, and store-specific privacy/backup policies.

## MVP scope

The app supports local Hive persistence, product inventory, low-stock alerts, sales and expense recording, transaction history, profit summaries, charts, exports, and settings. Firebase sync, authentication, payments, and release signing remain environment-specific configuration.
