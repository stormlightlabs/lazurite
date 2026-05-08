# Internationalization Milestones

## M0 - Foundation and English ARB

- [x] Add `flutter_localizations`, `intl`, `flutter.generate`, and `l10n.yaml`
- [x] Add canonical `lib/core/l10n/intl_en.arb`
- [x] Generate and track `AppLocalizations` Dart files
- [x] Wire `MaterialApp.router` delegates and supported locales
- [x] Add `context.l10n` helper for Lazurite widgets

## M1 - Core, Shared, Auth, Settings, Search

- [x] Localize app shell navigation, drawer labels, and common menu copy
- [x] Localize shared confirmation/error/moderation overlay copy
- [x] Localize login, saved account actions, and legal links
- [x] Localize settings sections, provider dialogs, and troubleshooting actions
- [x] Localize primary search tabs, placeholders, filters, and unavailable states
- [x] Add focused widget/localization tests for migrated surfaces

## M2 - Remaining Feature Surfaces

- [x] Localize feed cards, post menus, post actions, saved posts, and trending
- [ ] Localize compose flow, media alt text editors, draft/schedule states, and validation
- [ ] Localize profile screens, profile actions, reports, follows, lists, and starter packs
- [ ] Localize messages, notifications, alerts, and account switching sheets
- [ ] Localize moderation settings/detail screens and logs/devtools user-facing labels

## M3 - Locale QA and Secondary-Locale Strategy

- [ ] Add a pseudo-locale or generated QA locale for layout stress testing
- [ ] Audit hard-coded visible strings after M2
- [ ] Add locale-aware golden/widget coverage for dense layouts
- [ ] Decide first real non-English locale and translation ownership

## M4 - User-Facing Language Selection

- [ ] Add persisted language preference only after multiple real locales exist
- [ ] Add settings UI for system/default language and supported overrides
- [ ] Add tests for locale override persistence and app rebuild behavior
- [ ] Document translator workflow and release checklist
