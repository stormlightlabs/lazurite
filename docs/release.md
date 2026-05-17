---
title: Release and Distribution Guide
updated: 2026-05-17
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

## Versioning

Use `pubspec.yaml` as the tracked source of truth for local builds:

```yaml
version: 1.0.0+6
```

The part before `+` is Flutter's build name. Keep it numeric and App
Store-safe because iOS maps it to `CFBundleShortVersionString`. Do not put
prerelease text such as `-alpha.6` in the build name or iOS
`MARKETING_VERSION`.

The part after `+` is Flutter's build number. It maps to Android
`versionCode` and iOS `CFBundleVersion`, so it must be a monotonically
increasing integer for every uploaded build. It is not automatically "commits
since tag." Use the store or CI build sequence as the source of truth. For a
`v1.0.0-alpha.6` tag, build number `6` is valid only if `6` is the next upload
number for that app ID/package. If building from commits after the tag, assign
the next unused build number instead of reusing the tag's ordinal.

Keep platform files aligned:

- iOS: update the Runner target `MARKETING_VERSION` in
  `ios/Runner.xcodeproj/project.pbxproj` to the numeric public version, for
  example `1.0.0`. `Info.plist` should continue to read
  `$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)`.
- Android: keep `android/app/build.gradle.kts` reading `versionName` and
  `versionCode` from Flutter (`flutter.versionName` and `flutter.versionCode`).

For prerelease UI labels, update `AppVersion.prereleaseLabel` in
`lib/core/app/app_version.dart`. With `version: 1.0.0+6` and label `alpha`, the
app renders `Lazurite v1.0.0 alpha 6`.

After changing versions, run `flutter pub get`, then build from Flutter or the
IDE once so ignored local generated files such as
`ios/Flutter/Generated.xcconfig` and `android/local.properties` reflect the
current build name and number.

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

## Primary References

- Flutter Android release: <https://docs.flutter.dev/deployment/android>
- Flutter iOS release: <https://docs.flutter.dev/deployment/ios>
- Apple bundle short version (`CFBundleShortVersionString`): <https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleshortversionstring>
- Apple build version (`CFBundleVersion`): <https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleversion>
- Android app versioning: <https://developer.android.com/studio/publish/versioning>
- Android signing + Play App Signing: <https://developer.android.com/studio/publish/app-signing>
- Play App Signing help: <https://support.google.com/googleplay/android-developer/answer/9842756>
- App Store Connect uploads: <https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/>
- Apple explicit App ID / bundle ID requirements: <https://developer.apple.com/help/glossary/app-id/> and <https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleidentifier>
- AltStore PAL distribution: <https://faq.altstore.io/developers/distribute-with-altstore-pal>
- AltStore source format: <https://faq.altstore.io/developers/make-a-source>
- AltStore updates/version ordering: <https://faq.altstore.io/developers/updating-apps>
- Obtainium tracking/source behavior: <https://wiki.obtainium.imranr.dev/app_tracking/> and <https://wiki.obtainium.imranr.dev/sources/>
- GitHub releases: <https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository>
- GitHub release notes automation: <https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes>
- GitHub build provenance (artifact attestations): <https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations>
- GitHub release asset limits: <https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases>
- Firebase Flutter setup: <https://firebase.google.com/docs/flutter/setup>
- Firebase FCM Flutter setup: <https://firebase.google.com/docs/cloud-messaging/flutter/get-started>
- Firebase Android config (`google-services.json` + plugin): <https://firebase.google.com/docs/android/setup>
