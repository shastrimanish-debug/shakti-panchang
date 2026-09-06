# Shakti Panchang

**Shakti Panchang** — Panchang, Choghadiya, Muhurat, Yatra, Disha Shool, Kundali and **उमा** voice assistant.

### Commercial plan
**Shakti Panchang Premium — ₹99 / year**

Google Play subscription product ID: `shakti_panchang_yearly`

The app now contains a real Google Play Billing purchase/restore flow. Google Play is authoritative for the localized subscription price and purchase status.

### Brand
**Powered by SHIV SHAKTI**

### Release
Version **1.1.0+38**.

Release builds require a real Play upload keystore and intentionally fail when signing credentials are missing. See `docs/PLAY_RELEASE_SETUP.md`.

### CI
GitHub Actions performs Flutter analyze/tests and builds signed release APK + AAB after decoding the upload keystore from CI secrets.

Codemagic provides the equivalent `shakti_panchang_release` workflow.

### Privacy policy
A ready-to-host policy is included at `privacy_policy/index.html`. Host it at:

`https://myshivshakti.in/shakti-business/privacy-policy/`

### Astronomy accuracy note
`REFERENCE_VALIDATION_RESULT.json` records the existing 21-case reference validation. The release process must still run the current Flutter test suite and should not claim independent astronomical certification beyond the checked fixture.

**Powered by SHIV SHAKTI**
