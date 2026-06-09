# Label Details And Labeler Profiles Milestones

## M0 - Protocol Mapping And Data Models

- [x] Add `LabelContext` model for tapped labels
  - [x] Supports raw `Label` values from posts/profiles
  - [x] Supports moderation-cause-derived identifier + labeler DID
  - [x] Preserves subject URI/CID, created-at, expiry, and negation metadata when available
- [x] Add `LabelDetailData` model for UI-ready label detail content
  - [x] Includes labeler details, matching definition, effective preference, and subscription state
  - [x] Represents missing labeler and missing definition without throwing away raw protocol metadata
- [x] Unit tests for model construction from raw labels and moderation causes

## M1 - Label Detail Resolution

- [x] Add `LabelDetailRepository` with `getLabelDetail(LabelContext)`
- [x] Resolve labeler details via `app.bsky.labeler.getServices(detailed: true)`
- [x] Match `LabelValueDefinition.identifier` to the applied label identifier
- [x] Resolve localized display name/description through existing moderation UI helpers
- [x] Resolve current user preference and adult-content gating through existing helpers
- [x] Reuse Drift labeler policy cache for offline/cached rendering
- [x] Add in-flight lookup de-duplication/cache for repeated labeler DID taps
- [x] Unit tests for success, unknown labeler, no matching definition, offline cache, negation, and expiry

## M2 - Tappable Badge Plumbing

- [ ] Update `ModerationBadgeRow` to optionally render badges as tappable controls
- [ ] Preserve current passive rendering when no tap handler/details are supplied
- [ ] Carry enough data from moderation causes to build `LabelContext`
- [ ] Add tap handling for post badges
- [ ] Add tap handling for profile/account badges
- [ ] Add semantics labels and focus behavior for tappable badges
- [ ] Widget tests for passive badges, tappable badges, and keyboard/accessibility activation

## M3 - Label Detail Sheet

- [ ] Create `LabelDetailSheet` / `LabelDetailBottomSheet`
- [ ] Show localized label name and description when a definition exists
- [ ] Show raw identifier and no-description fallback when no definition exists
- [ ] Show labeler avatar/display name/handle/DID
- [ ] Show flags/chips for severity, blur target, default setting, effective preference, adult-only, negation, expiry
- [ ] Add collapsible protocol details for `src`, `uri`, `cid`, `val`, `cts`, `exp`, `neg`, and `ver`
- [ ] Add actions: open labeler profile, subscribe/unsubscribe, change label preference when possible
- [ ] Handle loading, retry, partial data, and cached/offline states
- [ ] Widget tests for all sheet states and actions

## M4 - Labeler Profile Route

- [ ] Add canonical `/labelers/:did` route and navigation helper
- [ ] Route existing moderation settings labeler taps through the same route/helper where practical
- [ ] Update `LabelerDetailScreen` title/header to behave as a labeler-service profile
- [ ] Add visible service URI and creator-account distinction
- [ ] Show `reasonTypes`, `subjectTypes`, and `subjectCollections` when present
- [ ] Add link/action to open the creator's normal account profile
- [ ] Preserve subscribe/unsubscribe and per-label preference editing
- [ ] Route tests for `/labelers/:did` and navigation from the sheet

## M5 - Integration Across Surfaces

- [ ] Wire post feed badges to open label details
- [ ] Wire thread/post detail badges to open label details
- [ ] Wire profile header/account badges to open label details
- [ ] Wire notification-related post/profile badges when displayed
- [ ] Ensure label taps do not trigger parent post/profile navigation accidentally
- [ ] Integration/widget tests for each surface

## M6 - Polish, Localization, And Verification

- [ ] Add all user-facing strings to l10n files
- [ ] Ensure long label names/descriptions wrap cleanly on narrow screens
- [ ] Add tablet behavior decision: sheet vs side panel/direct route
- [ ] Review copy for trust boundaries: third-party labeler text is not Lazurite endorsement
- [ ] Run `flutter analyze`
- [ ] Run `flutter test --reporter=failures-only` with timeout
- [ ] Update `docs/dev/social-features-and-moderation.md` after implementation is complete
