# Shakti Panchang Play Release V12

- Flutter pinned to 3.47.1 in GitHub Actions.
- Release signing is mandatory; no debug fallback.
- GitHub Actions decodes `KEYSTORE_BASE64` into the runner temp directory and generates `android/key.properties` at build time.
- Required repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.
- Release APK is verified with `apksigner`; AAB is verified with `jarsigner`.
- Google Play subscription product ID: `shakti_panchang_yearly`.
- Package/application ID: `com.shivshakti.shaktipanchang`.
