# SHAKTI PANCHANG — Feature Acceptance Checklist

## Architecture
- internal calculation engine/calculation provider remains an internal backend dependency.
- User-facing screens and UMA responses must not expose provider names.
- UI talks to domain/UMA abstractions, not provider-specific implementation.

## Prediction
UMA should provide structured interpretation for:
- Career
- Finance
- Marriage
- Education
- Business
- Property
- Foreign travel
- Children
- Dasha periods
- Transit periods
- Yog/Dosha
- Nakshatra/Rashi

Each prediction should follow:
**Finding → Why → Time period → Strength → Caution → Practical guidance/Remedy**

## Charts
- Avoid duplicate chart rendering on the same destination.
- Keep chart display and interpretation separate.
- Each chart has a single canonical presentation screen.

## Performance
- Avoid duplicate heavy calculations during rebuild.
- Prefer lazy loading for secondary modules.
- Cache deterministic chart calculations for the current birth profile/session.

## Release gate
Before APK/AAB:
1. `flutter analyze`
2. `flutter test` (or skip only when no test directory exists)
3. `flutter build apk --release`
4. `flutter build appbundle --release`

Do not declare the project final until the release gate passes.
