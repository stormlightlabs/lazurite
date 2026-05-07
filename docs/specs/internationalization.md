---
title: Internationalization
updated: 2026-05-07
---

## Summary

Lazurite uses Flutter `gen_l10n` with ARB files and `intl` for user-facing UI
strings. The v1 implementation is English-only, follows the system locale, and
establishes the app-local localization architecture needed for future real
translations.

## Current State

V1 localizes the foundation and first user-facing surface:

- App bootstrap localization delegates and supported locales
- App shell navigation, drawer, common buttons, dialogs, and error states
- Auth/login copy, saved account actions, and legal links
- Settings sections, common settings rows, provider dialogs, and troubleshooting
- Search tabs, common search placeholders, post filters, and starter-pack API
  unavailable messaging

Text intentionally not localized in v1:

- User-generated post/profile/list/feed content
- Handles, DIDs, AT URIs, URLs, record JSON, and log lines
- Server/API error details and externally localized moderation label values
- Remaining feature surfaces listed in `docs/tasks/internationalization.md`

## Architecture

Localization source lives in `lib/core/l10n/intl_en.arb`. `l10n.yaml` configures
Flutter generation:

- `arb-dir: lib/core/l10n`
- `template-arb-file: intl_en.arb`
- `output-localization-file: app_localizations.dart`
- `nullable-getter: false`
- `use-escaping: true`
- `required-resource-attributes: true`

Generated localization Dart files are checked in because Lazurite imports
`package:lazurite/core/l10n/app_localizations.dart` directly. Widgets should use
`context.l10n` from `package:lazurite/core/l10n/l10n.dart` when they already
have a `BuildContext`; app bootstrap can import `AppLocalizations` directly.

`MaterialApp.router` owns locale resolution through Flutter's default system
locale behavior. V1 does not add a persisted language setting or runtime picker.

## Key Naming Rules

- Prefer semantic keys over copy-shaped keys: `labelSettings`, not
  `settingsText`.
- Use prefixes consistently:
  - `button*` for button labels
  - `label*` for short labels, titles, tabs, and tooltips
  - `message*` for explanatory body text and helper text
  - `dialog*` for dialog-specific title/body copy
  - `error*` and `validation*` for failure copy
  - `format*` for parameterized messages
- Every ARB resource must include metadata because
  `required-resource-attributes` is enabled.
- Parameterized strings must use ARB placeholders with `type` and an example.

## Formatting Policy

Use `intl` for locale-sensitive dates and numbers. Context-free helpers in
`shared/utils/format_utils.dart` should accept an optional locale or use
`Intl.getCurrentLocale()` when no `BuildContext` is available.

Do not localize protocol constants, database keys, enum storage values, route
paths, asset paths, or provider keys.

## Testing Policy

Widget tests covering full localized screens should pump a `MaterialApp` or
`MaterialApp.router` with:

- `localizationsDelegates: AppLocalizations.localizationsDelegates`
- `supportedLocales: AppLocalizations.supportedLocales`

The `context.l10n` helper falls back to English for very small widget tests that
intentionally use a bare `MaterialApp`. Tests for English copy should keep
asserting visible English strings for now. When additional locales are added,
add locale-specific widget tests for key flows and locale-sensitive formatting
helpers.

## Known Limitations

- English is the only supported locale in v1.
- There is no in-app language picker.
- Some feature-specific strings remain hard-coded and are tracked as follow-up
  milestones.
- Plural, gender, and select messages are only introduced where v1 needs them;
  future translation work should revisit social-copy grammar in feed/profile
  surfaces.
