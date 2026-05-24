---
title: Internationalization
updated: 2026-05-24
---

Lazurite uses Flutter `gen_l10n` with ARB files and `intl`. English is the only
shipping locale today, but user-facing strings should still go through the
localization layer so future translations do not require another app-wide pass.

## Files

- Source strings: `lib/core/l10n/intl_en.arb`
- Generated API: `lib/core/l10n/app_localizations.dart` and companions
- Helper extension: `lib/core/l10n/l10n.dart`
- Generator config: `l10n.yaml`

Generated localization files are checked in because app code imports them
through `package:lazurite/core/l10n/app_localizations.dart`.

## Adding or changing copy

Use semantic keys, not keys shaped around the exact English text. Prefer prefixes
that describe where the string is used:

- `button*` for button labels
- `label*` for titles, tabs, short labels, and tooltips
- `message*` for helper or explanatory copy
- `dialog*` for dialog titles and body text
- `error*` and `validation*` for failures
- `format*` for parameterized strings

Every ARB entry needs metadata because `required-resource-attributes` is enabled.
Parameterized strings need typed placeholders and examples.

Do not localize protocol constants, route paths, database keys, enum storage
values, asset paths, handles, DIDs, AT URIs, URLs, raw record JSON, or log lines.
Server error details and externally localized moderation labels can remain as
provided by the service.

## Runtime behavior

`MaterialApp.router` uses Flutter's default system locale resolution. There is no
persisted in-app language picker yet. Add one only when the app ships more than
one real locale.

Use `context.l10n` from widgets that have a `BuildContext`. App bootstrap and
other non-widget code may import `AppLocalizations` directly.

## Tests

Widget tests for localized screens should pump a `MaterialApp` or
`MaterialApp.router` with:

```dart
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

Small widget tests may rely on the English fallback in `context.l10n`, but full
screen tests should include delegates. Keep asserting visible English copy until
another locale is added.
