---
title: Release Guide
updated: 2026-05-24
---

Use Android Studio and Xcode for the canonical signed-build flows. They surface
signing, provisioning, bundle ID, capability, and upload problems earlier than a
bare Flutter command. Command-line builds should replicate the same signing
configuration checked in or supplied by local/CI secrets.

## Release checklist

1. Confirm toolchain versions: `flutter --version`, `dart --version`, Android
   Studio, and Xcode.
2. Set `version:` in `pubspec.yaml` or pass matching build flags.
   - build name: public numeric version, for example `1.0.0`
   - build number: next store upload integer
3. Update `AppVersion.prereleaseLabel` in
   `lib/core/app/app_version.dart` when the UI should show an alpha/beta label.
4. Run gates:

   ```bash
   flutter pub get
   flutter analyze
   gtimeout 1200s flutter test --reporter=failures-only
   ```

5. Build from the tagged commit and upload the artifacts produced by that commit.

## Versioning

Flutter maps `version: 1.0.0+6` as follows:

- `1.0.0` -> Android `versionName` and iOS `CFBundleShortVersionString`
- `6` -> Android `versionCode` and iOS `CFBundleVersion`

Keep the build name numeric and App Store safe. Do not use values like
`1.0.0-alpha.6` for iOS `MARKETING_VERSION`. The build number must increase for
every store upload.

After changing versions, run `flutter pub get`, then build once from Flutter or
an IDE so ignored generated files reflect the new version.

## Android

Use Android Studio for release signing setup and Play Console uploads when
possible. Confirm the release variant uses the upload key, not debug signing.

Command-line equivalent:

```bash
flutter build appbundle --release \
  --build-name "$FLUTTER_BUILD_NAME" \
  --build-number "$FLUTTER_BUILD_NUMBER"
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Play internal
testing first. For non-Play channels, build and sign APKs instead.

## iOS

Use Xcode to validate bundle ID, signing team, provisioning profile, entitlements,
and capabilities. Archive from Xcode for the safest App Store Connect flow, or
replicate the same signing setup from the command line.

Command-line equivalent:

```bash
flutter build ipa --release \
  --build-name "$FLUTTER_BUILD_NAME" \
  --build-number "$FLUTTER_BUILD_NUMBER"
```

Upload `build/ios/ipa/*.ipa` with Xcode Organizer or Transporter, then validate
through TestFlight before review.

## Direct distribution

GitHub Releases, AltStore, and Obtainium builds must still come from the tagged
commit and use proper release signing. Attach checksums for downloadable assets:

```bash
shasum -a 256 build/app/outputs/flutter-apk/*.apk build/ios/ipa/*.ipa > checksums.txt
```

AltStore PAL uses Apple's alternative distribution package flow. AltStore Classic
uses a signed IPA and source JSON. Obtainium needs a stable release source with
signed APK download URLs.

## Firebase push configuration

Use `.env.example` as the public variable list and keep real values in local or
CI secrets. Firebase files are checked in to VCS, and must remain at:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`, included in the Runner target

In Xcode, enable Push Notifications and Background Modes as required by the
notification implementation. Upload the APNs key or certificate in Firebase
Console before expecting production iOS push delivery.
