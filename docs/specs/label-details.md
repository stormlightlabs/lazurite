---
title: Label Details And Labeler Profiles Spec
updated: 2026-06-08
---

## Summary

Make moderation labels actionable wherever Lazurite already renders them on
accounts and posts. Tapping a label should explain:

- the label that was applied
- the account/service that applied it
- the label definition, including localized name, description, severity,
  default preference, blur target, and adult-only flag when available
- the concrete label event metadata from the protocol (`src`, `uri`, `cid`,
  `cts`, `exp`, `neg`)
- how the active user's current preferences treat that label

The feature should reuse the existing labeler detail and subscription machinery
instead of creating a separate moderation stack.

## Protocol/API Data Available

### Applied labels

Labels attached to posts, profiles, labeler views, and other resources use
`com.atproto.label.defs#label`. The generated SDK exposes:

```dart
Label(
  src: String,       // DID of the account/service that applied the label
  uri: String,       // AT URI or DID of the labelled subject
  val: String,       // short label identifier
  cts: DateTime,     // creation timestamp
  ver: int?,         // label object version
  cid: String?,      // labelled record CID, if record-version-specific
  neg: bool?,        // true when this negates/removes an earlier label
  exp: DateTime?,    // expiry time, if temporary
  sig: Map<String, dynamic>?,
)
```

The applied label itself does not carry localized copy. It only names the
labeler (`src`) and the label identifier (`val`). Lazurite must resolve `src`
through `app.bsky.labeler.getServices` to get the labeler's published policies.

### Labeler service details

`app.bsky.labeler.getServices(dids: [...], detailed: true)` returns
`app.bsky.labeler.defs#labelerViewDetailed` for known labeler services. The SDK
exposes:

```dart
LabelerViewDetailed(
  uri: AtUri,
  cid: String,
  creator: ProfileView,
  policies: LabelerPolicies,
  indexedAt: DateTime,
  likeCount: int?,
  viewer: LabelerViewerState?, // currently only viewer.like
  labels: List<Label>?,
  reasonTypes: List<ReasonType>?,
  subjectTypes: List<SubjectType>?,
  subjectCollections: List<String>?,
)
```

`policies` includes:

```dart
LabelerPolicies(
  labelValues: List<LabelValue>,
  labelValueDefinitions: List<LabelValueDefinition>?,
)
```

Each `LabelValueDefinition` provides the description-level data needed by this
feature:

```dart
LabelValueDefinition(
  identifier: String,
  severity: LabelValueDefinitionSeverity, // inform, alert, none, or unknown
  blurs: LabelValueDefinitionBlurs,       // content, media, none, or unknown
  defaultSetting: LabelValueDefinitionDefaultSetting?,
  adultOnly: bool?,
  locales: List<LabelValueDefinitionStrings>, // localized name/description
)
```

### Subscription data

Subscription state is not a graph follow. Bluesky stores active labelers in the
actor preferences as `app.bsky.actor.defs#labelersPref`. Lazurite already wraps
this in `ModerationService.subscribeToLabeler`, `unsubscribeFromLabeler`,
`setLabelPreference`, `getSubscribedLabelers`, and `getLabelerDetails`.

Labeler views also expose `viewer.like`, but the available SDK surface does not
show a protocol-level subscribe/follow field on `LabelerViewerState`. For this
feature, "subscribe" means updating moderation preferences, not following the
creator account.

## UX

### Entry points

- Every moderation badge rendered for a post or profile is tappable.
- Tapping a badge opens a label detail sheet when the app already has the
  concrete `Label` object for that badge.
- If the UI only has a moderation cause/descriptor, the tap target should pass
  `labelerDid` and `identifier`; the detail resolver can still show the
  definition, but protocol event metadata may be absent.
- The sheet has a primary action to open the full labeler profile/detail screen.

### Label detail sheet

The sheet is a short, contextual explanation:

1. Label name, resolved from `LabelValueDefinition.locales` using current locale.
2. Labeler identity: avatar, display name, handle, DID.
3. Description from the localized definition, or a clear fallback when the
   labeler publishes only the raw value.
4. Flags/chips:
   - severity
   - blurs target
   - default setting
   - active user setting
   - adult-only
   - negation label
   - expires/expired
5. Applied-label metadata in a collapsed "Protocol details" section.
6. Actions:
   - Open labeler details
   - Subscribe/unsubscribe to labeler when not the built-in labeler
   - Change this label's preference when a definition exists

### Labeler profile/detail screen

Lazurite already has `LabelerDetailScreen`, which includes the labeler creator
profile, published policies, label definitions, per-label preferences, and
subscribe/unsubscribe controls. Feature work should evolve that screen into the
canonical labeler profile rather than add a parallel profile type.

Recommended additions:

- route alias such as `/labelers/:did` so labels can deep-link to labeler
  profiles from feeds, threads, profiles, settings, and future search results
- clearer title: "Labeler" plus display name/handle once loaded
- explicit account/service distinction: show the creator account and the
  labeler service URI (`at://did/app.bsky.labeler.service/self`)
- published scope metadata when present: `reasonTypes`, `subjectTypes`, and
  `subjectCollections`
- optional link to the creator's normal user profile for social actions such as
  follow, mute, or block

## Should Labeler Profiles Be Added?

Yes, but as labeler-service profiles, not by overloading normal account
profiles. Users need a trusted place to inspect a labeler's policies before
subscribing, and subscription is a moderation preference. The existing
`LabelerDetailScreen` is already most of that experience, so the feature should:

- expose it from tapped labels
- make it routable and deep-linkable
- keep subscribe/unsubscribe in the labeler detail surface
- provide a separate link to the creator's ordinary account profile when users
  want normal social actions

This avoids confusing "follow account" with "subscribe to this moderation
service".

## Data And Architecture

### Domain models

Add small app-level models that decouple UI from SDK unions:

```dart
class LabelContext {
  final Label? appliedLabel;
  final String labelerDid;
  final String identifier;
  final String? subjectUri;
  final String? subjectCid;
}

class LabelDetailData {
  final LabelContext context;
  final LabelerViewDetailed? labeler;
  final LabelValueDefinition? definition;
  final KnownContentLabelPrefVisibility effectivePreference;
  final bool isSubscribed;
}
```

`LabelContext` should be built from:

- moderation causes generated by `poptart_bluesky_moderation`
- raw `labels` lists on `PostView`, `ProfileView`, `ProfileViewBasic`, and
  `ProfileViewDetailed`
- fallback descriptor data when only identifier/labeler DID is available

### Repository/service layer

Extend `ModerationService` or add a thin `LabelDetailRepository` around it:

- `Future<LabelDetailData> getLabelDetail(LabelContext context)`
- fetch labeler details with `getLabelerDetails(context.labelerDid)`
- locate `definition` by `identifier == context.identifier`
- resolve current preference with existing helper methods
- surface cached labeler policy data when offline if Drift has it
- batch/cache in-flight labeler lookups to avoid one request per badge in dense
  feeds

### Presentation

- Convert `ModerationBadgeRow` from passive chips into optional tappable chips.
- Add `onBadgeTap(ModerationBadgeDescriptor descriptor)` or pass richer
  `LabelContext` values alongside descriptors.
- Create a `LabelDetailSheet`/`LabelDetailBottomSheet` for contextual details.
- Reuse `LabelerDetailScreen` for the full profile.
- Add a route helper for `/labelers/:did`.

## Offline And Failure Behavior

- If labeler policies are cached, render them with an "offline/cached" note.
- If the labeler cannot be resolved, still show the applied label metadata and
  raw identifier.
- If the labeler publishes `labelValues` but omits a matching definition, show
  the raw value and explain that no description is published.
- Never block post/profile rendering on labeler detail loading. Details load only
  after the user taps.

## Security And Trust Notes

- Treat label definitions as labeler-published text, not app-authored policy.
- Do not imply Lazurite endorses a third-party labeler.
- Keep normal account moderation on the labeler creator profile; labeler
  descriptions and avatars should use existing profile moderation decisions.
- Do not expose signatures as user-facing trust proof unless the app actually
  verifies them.

## Testing Expectations

- Unit tests for resolving `LabelDetailData` from label context, including
  missing labeler, missing definition, negation, expiry, and cached/offline data.
- Widget tests for tappable moderation badges opening the sheet.
- Widget tests for sheet content, subscription toggle, preference changes, and
  route to labeler detail.
- Existing moderation settings tests should continue to cover the labeler detail
  screen; add route/deep-link coverage.

## Open Questions

- Whether to expose `reasonTypes`, `subjectTypes`, and `subjectCollections` in
  the sheet or only on the full labeler profile.
- Whether a tap should open a compact sheet first or navigate directly to the
  full labeler profile on large/tablet layouts.
- Whether labels generated by the built-in Bluesky labeler should be visually
  distinguished from third-party labelers beyond the existing built-in chip.
