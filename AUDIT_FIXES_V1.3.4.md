# Audit fixes — Shakti Panchang 1.3.4+48

- Theme/locale now apply immediately via `ChangeNotifier` + `ListenableBuilder`.
- Daily Rashifal no longer calls `setState` after dispose; location-null path is mounted-safe.
- Numerology screen disposes its `TextEditingController`.
- Book home now includes Daily Rashifal and Numerology chapters (they were only on `HomeScreen`, which is not the app entry).
- README version aligned with `pubspec.yaml` 1.3.4+48.
