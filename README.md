# Shakti Panchang

**Shakti Panchang** — Panchang, Choghadiya, Muhurat, Yatra and Disha Shool with **उमा** voice assistant.

### Commercial plan
**Shakti Panchang Premium — ₹99 / year**

### Brand
**Powered by SHIV SHAKTI**

### Current milestone
V10.1 Commercial branding update.

> Flutter SDK/build and live store billing validation are intentionally the next post-V10 stage.

## Codemagic Debug

The Android project is checked into the repository with a pinned build toolchain:

- Gradle 8.14.3
- AGP 8.11.1
- `android.newDsl=false`

Codemagic does **not** run `flutter create`, so it cannot overwrite these versions.

Workflow: `shakti_panchang_debug`

Artifact: `app-debug.apk`

**Powered by SHIV SHAKTI**


## Full astrology calculation pass
`FullAstrologyEngine` now provides the integration facade for full KP cusp/significator output, Yogini Dasha timing, and an astronomical solar-return search used by Varshaphal. These outputs are calculated from the project's astronomical engine rather than generated as generic AI text.
