# Shakti Panchang — Google Play release setup

## 1. Google Play subscription
Create a **subscription** with this exact product ID:

`shakti_panchang_yearly`

Create and activate its yearly base plan and set the intended India price (₹99/year). Configure the free trial in Play Console if desired. The app reads the localized price returned by Google Play, so the store price is authoritative.

Before purchase testing, publish the subscription/base plan to a testing track and add the tester account as a license tester.

## 2. Upload signing key
Never commit the private keystore.

Required CI secrets/environment variables:

- `KEYSTORE_BASE64` — base64 of the Play upload `.jks`/`.keystore`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD` (optional if it is the same as the keystore password)

The release Gradle configuration intentionally **fails** if a release signing key is missing. It no longer falls back to a debug key.

For local release builds, copy `android/key.properties.example` to `android/key.properties` and fill in the real values.

## 3. GitHub Actions
The workflow builds both a signed release APK and signed release AAB after:

- Flutter/Dart version output
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Rust script syntax check

Configure the four secrets above in GitHub repository Settings → Secrets and variables → Actions.

## 4. Codemagic
Create a secure environment group named `shakti_panchang_play_signing` containing the same variables. The `shakti_panchang_release` workflow then creates `android/key.properties` only inside the CI workspace.

## 5. Privacy policy hosting
Upload `privacy_policy/index.html` to:

`public_html/shakti-business/privacy-policy/index.html`

The Play Console URL should be:

`https://myshivshakti.in/shakti-business/privacy-policy/`

Confirm the URL returns HTTP 200 in a normal browser before submitting the Play review.

## 6. Ads declaration
This source does not include an advertising SDK or the Android Advertising ID permission. If ads are added later, update the Play Console declaration and Data Safety form to match the new build.

## 7. Data Safety reminder
This build uses device location for selected features and can send GPS/search information to Nominatim for geocoding. Voice input uses the OS speech-recognition stack. The Play Billing payment instrument itself is handled by Google Play; the app receives purchase/subscription status. The Play Console Data Safety answers must match the final uploaded build and any SDK behavior.
