---
title: Release Audit - Apple App Store + Google Play
updated: 2026-04-15
scope: Repository audit for likely store submission blockers or high-risk policy issues.
---

## Sources

- Apple App Review Guidelines: <https://developer.apple.com/app-store/review/guidelines/>
  - 1.2 User-Generated Content requirements
  - 5.1.1 Data Collection and Storage (Privacy Policies)
  - 4.8 Login Services (third-party login exception for service clients)
- Google Play User Data policy: <https://support.google.com/googleplay/android-developer/answer/10144311?hl=en>
  - Privacy Policy requirement
  - Account deletion requirement (if account creation is supported)
- Google Play Developer Programme Policy (UGC section): <https://support.google.com/googleplay/android-developer/answer/16070163>
  - UGC terms acceptance + moderation expectations

## Findings

### No in-app Privacy Policy link/text

- Policy mapping:
  - Apple 5.1.1(i): privacy policy must be linked in App Store Connect and in-app in an easily accessible manner.
  - Google Play User Data: privacy policy link/text must exist in Play Console and in-app.
- Evidence in app:
  - Login has no privacy/terms surface: `lib/features/auth/presentation/login_screen.dart` (see UI around lines 54-205).
  - Settings has no legal/privacy entry: `lib/features/settings/presentation/settings_screen.dart` (lines 69-151).
  - About page has external links and email only, no privacy policy link: `lib/features/settings/presentation/about_screen.dart` (lines 8-97).
  - Existing backlog confirms missing policy: `docs/TODO.md` (lines 62-65).
- Impact: High probability of rejection by both stores until fixed.

### High Risk (Google Play UGC): No explicit Terms/User Policy acceptance before posting UGC

- Policy mapping:
  - Google Play UGC policy requires robust moderation, including requiring acceptance of Terms of Use and/or user policy before users create/upload UGC.
- Evidence in app:
  - Compose allows direct posting with no terms acceptance gate: `lib/features/compose/presentation/compose_screen.dart` (lines 567-588, especially Post action at 584-587).
  - No in-app terms/user policy screen found in `lib/`.
- Impact: Elevated Play policy risk for social/UGC apps.

### Moderate Risk (Apple UGC 1.2): Posting-side objectionable-content controls are not explicit

- Policy mapping:
  - Apple 1.2 says UGC/social apps should include a method for filtering objectionable material from being posted.
- Evidence:
  - Reporting/blocking exists (good):
    - `lib/features/profile/presentation/widgets/profile_action_buttons.dart` (Report/Block UI around lines 85-140).
    - `lib/features/profile/presentation/widgets/report_dialog.dart` (report flow lines 10-220).
  - Moderation controls exist for viewed content (good): `lib/features/settings/presentation/settings_screen.dart` (Moderation section lines 75-77).
  - No explicit compose-time objectionable-content filter is visible in compose flow.
- Impact: Could pass if platform-side moderation is accepted by review, but still a non-trivial risk without clear reviewer notes.

### Release Engineering Blocker

- Android release is configured to use debug signing:
  - `android/app/build.gradle.kts` lines 33-38.
- Android application ID is still placeholder:
  - `android/app/build.gradle.kts` lines 23-25 (`com.example.lazurite`).
- iOS bundle identifiers are still placeholder:
  - `ios/Runner.xcodeproj/project.pbxproj` lines 498, 681, 704 (`com.example.lazurite`).
- iOS release config currently shows developer signing identity:
  - `ios/Runner.xcodeproj/project.pbxproj` line 642 (`iPhone Developer`).
- Clarification:
  - `org.stormlightlabs.lazurite.auth` appears in `Info.plist` URL type name (`CFBundleURLName`) and is not itself a placeholder bundle ID.
- Impact: Submission can fail operationally or be blocked in release pipeline.

### Reviewer-access risk for App Store

- Apple "Before You Submit" requires full reviewer access (demo account or demo mode for account-based features).
- App is account-based and login-gated; no repo evidence of dedicated reviewer/demo path.
- Impact: Common review delay/rejection if review notes do not include working credentials.

## OK

- In-app report mechanism exists for posts/accounts:
  - `lib/features/profile/presentation/widgets/report_dialog.dart`.
- Block/mute actions exist:
  - `lib/features/profile/presentation/widgets/profile_action_buttons.dart`.
- User-reachable contact info exists:
  - Email link in About: `lib/features/settings/presentation/about_screen.dart` line 11 + UI lines 90-93.
- Sign in with Apple requirement appears likely exempt:
  - App behaves as a client for a specific third-party service (Bluesky), matching Apple 4.8 exception language.

## Fixes (In Priority Order)

- [ ] Add a dedicated Legal screen and surface:
  - [ ] Privacy Policy (in-app link + readable text summary)
  - [ ] Terms of Use / User Policy
  - [ ] Reachable from login and settings/about
- [ ] Add UGC policy acceptance flow before first create/upload action (compose, media upload, messages if applicable).
- [ ] Document moderation operations in policy/reviewer notes:
  - [ ] How reports are handled and SLA
  - [ ] What objectionable content rules apply
- [ ] Replace placeholder identifiers and release signing setup:
  - [ ] Android `applicationId`
  - [ ] Android release signing config (non-debug)
  - [ ] iOS bundle IDs + distribution signing
- [ ] Prepare App Store review notes with working reviewer credentials/demo path.
- [ ] Verify account deletion obligations:
  - [ ] If any account creation is enabled in-app, add in-app deletion entry point per Apple/Google rules.
