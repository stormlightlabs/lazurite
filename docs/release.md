---
title: Release and Distribution Guide
updated: 2026-05-02
---

## Shared Release Baseline

1. Pin and verify toolchain.
   - `flutter --version`
   - `dart --version`
2. Set version in `pubspec.yaml` and/or pass build flags.
   - `--build-name` => human version (for example `1.4.0`)
   - `--build-number` => monotonically increasing integer
3. Run release gates.
   - `flutter pub get`
   - `flutter analyze`
   - `gtimeout 1200s flutter test --reporter=failures-only`
4. Tag immutable source.
   - `git tag vX.Y.Z`
5. Build store artifacts from that exact tag/commit.

## Environment Variables

Use the root `.env.example` as the canonical variable list. Keep real values in untracked secrets (`.env.local`, CI secrets manager, etc.).

## Google Play (Android)

### Build

1. Configure real release signing (upload key), not debug signing.
2. Build AAB (preferred by Google Play):

      ```bash
      flutter build appbundle --release \
      --build-name "$FLUTTER_BUILD_NAME" \
      --build-number "$FLUTTER_BUILD_NUMBER"
      ```

3. Artifact: `build/app/outputs/bundle/release/app-release.aab`

### Deploy

1. Enroll in Play App Signing.
2. Upload `app-release.aab` to Internal testing first.
3. Promote to closed/open/production after validation.

### Notes

- If you need the same signing key across multiple stores, provide your own app signing key when configuring Play App Signing.
- For non-Play Android channels, ship signed APKs (Play consumes AAB; side channels consume APK).

## Apple App Store (iOS)

### Build

1. Use an explicit App ID + matching bundle ID.
2. Build signed IPA:

      ```bash
      flutter build ipa --release \
      --build-name "$FLUTTER_BUILD_NAME" \
      --build-number "$FLUTTER_BUILD_NUMBER"
      ```

3. Artifact: `build/ios/ipa/*.ipa`

### Deploy

1. Upload using Xcode or Transporter to App Store Connect.
2. Wait for processing.
3. Ship through TestFlight (internal/external) first.
4. Submit selected build for App Review.

### Notes

- App Store Connect associates build using bundle ID + version + build string.
- As of 2026, Apple requires Xcode 14+ for uploads.

## AltStore.io

AltStore distribution has two distinct paths.

### AltStore PAL (EU marketplace path)

#### Build/Package

1. Build iOS release (`flutter build ipa --release`).
2. Submit via App Store Connect with Notarization (or App Store approval, which also results in notarization).
3. Download the Alternative Distribution Package (ADP).
4. Host ADP exactly as-delivered; preserve directory hierarchy and do not modify `manifest.json`.

#### Deploy

1. Accept Apple Alternative EU Terms Addendum.
2. Register Developer ID with AltStore PAL API.
3. Add returned marketplace token in App Store Connect Integrations.
4. Publish a Source JSON with required app/version metadata.

### AltStore Classic (sideloaded IPA path)

#### Build

1. Build/sign IPA (`flutter build ipa --release`).
2. Host IPA at stable HTTPS URL.

#### Deploy

1. Publish/update Source JSON.
2. Keep newest entry first in `versions` array.
3. Ensure each release updates `version` (`CFBundleShortVersionString`) and/or `buildVersion` (`CFBundleVersion`).
4. Include accurate `downloadURL`, `size`, and optional `minOSVersion` / `maxOSVersion`.

### Notes

- AltStore determines latest release by `versions` ordering, not dates.
- AltStore checks declared app permissions/entitlements against downloaded app package.

## F-Droid

### Build Strategy

1. Decide target:
   - Main F-Droid repo, or
   - Your own F-Droid-compatible repo.
2. For main F-Droid repo, create an `fdroid` flavor without proprietary SDKs (Firebase/Crashlytics/Play Services tracking dependencies are not allowed in main repo).
3. Build signed deterministic APK for that flavor.

Recommended flavor command pattern:

```bash
flutter build apk --release \
  --flavor fdroid \
  --target lib/main_fdroid.dart \
  --build-name "$FLUTTER_BUILD_NAME" \
  --build-number "$FLUTTER_BUILD_NUMBER"
```

### Deploy

1. Prepare fdroiddata metadata and submit inclusion proposal (prefer metadata merge request path).
2. Keep upstream releases tagged.
3. Aim for reproducible builds from day one (strongly recommended by F-Droid, harder to retrofit later).

### Notes

- If Firebase push is required in Play/App Store builds, maintain a clean non-proprietary F-Droid flavor where push is disabled or replaced.

## Obtainium (Android direct update channel)

### Build

1. Produce signed APK artifacts for direct install.
2. Prefer a stable, machine-discoverable release URL source (typically GitHub Releases).

### Deploy

1. Publish release where source exposes:
   - version identifier
   - at least one APK download URL
2. If multiple APK variants exist, keep filenames explicit (`arm64-v8a`, `universal`, etc.) so users can filter reliably.

### Notes

- Obtainium supports GitHub, GitLab, F-Droid repos, direct APK links, and HTML fallback.
- Cross-store signing matters: updating from F-Droid-signed to non-F-Droid-signed builds may fail due to signature mismatch.

## GitHub Releases

### Build

1. Build release artifacts from tagged commit (`vX.Y.Z`).
2. Generate checksums for all distributables.

Example:

```bash
shasum -a 256 build/app/outputs/flutter-apk/*.apk build/ios/ipa/*.ipa > checksums.txt
```

### Deploy

1. Create release from tag.
2. Attach binaries (`.aab`, `.apk`, `.ipa`, `checksums.txt`, optional symbols/maps).
3. Use generated release notes, then curate manually.

CLI example:

```bash
gh release create "v${FLUTTER_BUILD_NAME}" \
  --generate-notes \
  build/app/outputs/bundle/release/app-release.aab \
  build/app/outputs/flutter-apk/*.apk \
  build/ios/ipa/*.ipa \
  checksums.txt
```

### Hardening (Recommended)

- Add artifact attestations in GitHub Actions for build provenance.
- Keep each release asset < 2 GiB.

## Firebase Push Notifications (iOS + Android)

### 1) Firebase Project and App Registration

1. Install CLI tooling.
   - `firebase login`
   - `dart pub global activate flutterfire_cli`
2. Run:

      ```bash
      flutterfire configure
      ```

3. Commit generated `lib/firebase_options.dart`.

### 2) Platform Config Files

1. Android: place `google-services.json` at `android/app/google-services.json`.
2. iOS: place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist` and include it in Runner target.

### 3) Android Gradle Wiring

1. Add Google services Gradle plugin in project/plugin management.
2. Apply `com.google.gms.google-services` in app module.

### 4) Apple Push Prerequisites

1. In Xcode, enable `Push Notifications` capability.
2. In Xcode Background Modes, enable:
   - `Background fetch`
   - `Remote notifications`
3. Upload APNs auth key (`.p8`, Key ID, Team ID) in Firebase Console > Project Settings > Cloud Messaging.

### 5) App Initialization and Runtime

1. Initialize with generated options:

      ```dart
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      ```

2. Request user notification permission (iOS) before expecting token delivery.
3. Register and sync FCM token with backend; rotate on refresh.

### 6) Channel-Specific Caveat

- F-Droid mainline build should not include proprietary Firebase dependencies.
Keep push-enabled binaries for Play/App Store/AltStore/Obtainium, and maintain a non-Firebase F-Droid flavor.

## Primary References

- Flutter Android release: <https://docs.flutter.dev/deployment/android>
- Flutter iOS release: <https://docs.flutter.dev/deployment/ios>
- Android signing + Play App Signing: <https://developer.android.com/studio/publish/app-signing>
- Play App Signing help: <https://support.google.com/googleplay/android-developer/answer/9842756>
- App Store Connect uploads: <https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/>
- Apple explicit App ID / bundle ID requirements: <https://developer.apple.com/help/glossary/app-id/> and <https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleidentifier>
- AltStore PAL distribution: <https://faq.altstore.io/developers/distribute-with-altstore-pal>
- AltStore source format: <https://faq.altstore.io/developers/make-a-source>
- AltStore updates/version ordering: <https://faq.altstore.io/developers/updating-apps>
- F-Droid inclusion policy: <https://f-droid.org/en/docs/Inclusion_Policy/>
- F-Droid inclusion workflow: <https://f-droid.org/en/docs/Inclusion_How-To/>
- F-Droid reproducible builds: <https://f-droid.org/docs/Reproducible_Builds/>
- Obtainium tracking/source behavior: <https://wiki.obtainium.imranr.dev/app_tracking/> and <https://wiki.obtainium.imranr.dev/sources/>
- GitHub releases: <https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository>
- GitHub release notes automation: <https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes>
- GitHub build provenance (artifact attestations): <https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations>
- GitHub release asset limits: <https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases>
- Firebase Flutter setup: <https://firebase.google.com/docs/flutter/setup>
- Firebase FCM Flutter setup: <https://firebase.google.com/docs/cloud-messaging/flutter/get-started>
- Firebase Android config (`google-services.json` + plugin): <https://firebase.google.com/docs/android/setup>
