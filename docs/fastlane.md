# Fastlane Guide

This project includes a first-pass Fastlane setup for local and GitHub Actions usage.

## Scope

- Build artifacts (no production signing in this pass)
- Screenshot automation scaffolding for iOS and Android
- Manual GitHub Actions workflow dispatch for running lanes

## Prerequisites

- Flutter SDK
- Ruby 3.x and Bundler
- Xcode + iOS Simulator tooling (for iOS lanes)
- Android SDK + emulator/device tooling (for Android lanes)

Install gem dependencies:

```sh
bundle install
```

Create local env file:

```sh
cp .env.example .env
```

## Local Commands

List lanes:

```sh
bundle exec fastlane lanes
```

Build lanes:

```sh
bundle exec fastlane ios build
bundle exec fastlane android build
```

Screenshot lanes:

```sh
bundle exec fastlane ios screenshots
bundle exec fastlane android screenshots
```

Equivalent `just` wrappers are available:

```sh
just fastlane-lanes
just fastlane-ios-build
just fastlane-android-build
just fastlane-ios-screenshots
just fastlane-android-screenshots
```

## Authentication for Screenshots

The app is auth-gated, so screenshot lanes currently assume a dedicated test account.

Required environment variables:

- `BSKY_TEST_HANDLE`
- `BSKY_TEST_APP_PASSWORD`

Current state:

- iOS screenshots require `ios/RunnerUITests` to exist and perform app-password login before calling `snapshot(...)`.
- Android screenshots require `android/app/src/androidTest` screengrab tests that log in and call `Screengrab.screenshot(...)`.

Both lanes fail fast with actionable TODO messages until those test hooks are implemented.

## Build Artifacts

Fastlane copies outputs to:

- iOS: `build/fastlane_artifacts/ios`
- Android APK: `build/fastlane_artifacts/android/apk`
- Android AAB: `build/fastlane_artifacts/android/aab`

## GitHub Actions

Workflow file: `.github/workflows/fastlane.yml`

Trigger mode:

- `workflow_dispatch` only
- inputs:
  - `platform`: `ios` or `android`
  - `lane`: `build` or `screenshots`

The workflow uploads any generated artifacts/screenshots.

## Keys and Secrets TODOs

This setup intentionally defers production signing/distribution. Add these secrets later as you enable those lanes.

### iOS/App Store Connect

- `ASC_KEY_ID` (TODO)
- `ASC_ISSUER_ID` (TODO)
- `ASC_PRIVATE_KEY` (TODO)
- `MATCH_GIT_URL` (TODO if using match)
- `MATCH_PASSWORD` (TODO if using match)

Current optional iOS identity variables:

- `IOS_APP_IDENTIFIER`
- `APP_STORE_CONNECT_APPLE_ID`
- `APPLE_DEVELOPER_TEAM_ID`
- `APP_STORE_CONNECT_TEAM_ID`

### Android/Play

- `ANDROID_KEYSTORE_BASE64` (TODO)
- `ANDROID_KEYSTORE_PASSWORD` (TODO)
- `ANDROID_KEY_ALIAS` (TODO)
- `ANDROID_KEY_PASSWORD` (TODO)
- `PLAY_SERVICE_ACCOUNT_JSON` (TODO)

Current optional Android variable:

- `ANDROID_APP_IDENTIFIER`

## How to Obtain Non-Bluesky Keys/Secrets

This section covers only Apple/Google signing and store automation credentials.

### App Store Connect API (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`)

1. Sign in to App Store Connect with an account that can manage API keys.
2. Open `Users and Access` -> `Integrations` -> `App Store Connect API`.
3. Create a Team API key with the minimum role needed for release automation.
4. Download the `.p8` key file immediately (Apple allows a one-time download).
5. Save values:
   - `ASC_KEY_ID`: Key ID shown for the generated key.
   - `ASC_ISSUER_ID`: Issuer ID shown in the API section.
   - `ASC_PRIVATE_KEY`: The full `.p8` file content stored as a GitHub secret.

### Apple Team/App Identity (`APPLE_DEVELOPER_TEAM_ID`, `APP_STORE_CONNECT_TEAM_ID`, `APP_STORE_CONNECT_APPLE_ID`)

1. `APPLE_DEVELOPER_TEAM_ID`:
   - Get this from Apple Developer account membership details.
2. `APP_STORE_CONNECT_TEAM_ID`:
   - Use your App Store Connect team ID from account/team settings.
3. `APP_STORE_CONNECT_APPLE_ID`:
   - Use the Apple ID email used for App Store Connect automation ownership.

### Android Signing (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`)

1. Generate a release keystore (example):

    ```sh
    keytool -genkeypair -v \
      -keystore upload-keystore.jks \
      -alias upload \
      -keyalg RSA -keysize 2048 -validity 10000
    ```

2. Base64 encode the keystore for GitHub secret storage:

    ```sh
    base64 -i upload-keystore.jks | pbcopy
    ```

3. Store secrets:
   - `ANDROID_KEYSTORE_BASE64`: base64 value of `.jks`.
   - `ANDROID_KEYSTORE_PASSWORD`: keystore password.
   - `ANDROID_KEY_ALIAS`: alias used at creation (example `upload`).
   - `ANDROID_KEY_PASSWORD`: key password (may match keystore password).

### Google Play API (`PLAY_SERVICE_ACCOUNT_JSON`)

1. In Google Play Console, open `Users and permissions` and invite/link a service account from Google Cloud.
2. In Google Cloud IAM, create a service account key (JSON) for that account.
3. Grant least-privilege Play permissions needed for release automation.
4. Store the JSON securely:
   - Either the raw JSON as `PLAY_SERVICE_ACCOUNT_JSON` (multi-line secret), or
   - base64-encode it and decode during workflow runtime.

### Optional Match Secrets (`MATCH_GIT_URL`, `MATCH_PASSWORD`)

1. Create a private certificates/profiles repository.
2. Set `MATCH_GIT_URL` to that repository URL.
3. Set `MATCH_PASSWORD` to the encryption passphrase used by match.

### Secret Hygiene

- Use repository or environment-level GitHub secrets, not committed files.
- Rotate any secret immediately if leaked.
- Restrict secret access to release workflows/environments.

## Notes

- CI artifact lanes are non-distribution lanes.
- Adding signed IPA/AAB and store upload lanes is a follow-up once keys are provisioned.
