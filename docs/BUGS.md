---
title: Bugs
updated: 2026-03-18
---

## Checklist

- [x] [1. Draft Save Redundancy — Cancel Prompts After Explicit Save](#1-draft-save-redundancy--cancel-prompts-after-explicit-save)
- [ ] [2. Character Counter — No Initial State](#2-character-counter--no-initial-state)
- [ ] [3. Composer Layout — Drafts Should Be Inline, Not Full-Screen](#3-composer-layout--drafts-should-be-inline-not-full-screen)

## 1. Draft Save Redundancy — Cancel Prompts After Explicit Save

**Status:** Broken — user can save a draft, then immediately be asked to save again on
cancel.

**Problem:** The AppBar has both a "Save Draft" button (line 502) and a "Cancel" button
(line 497). If the user taps "Save Draft" → draft is saved and a snackbar confirms it.
If the user then taps "Cancel", `_handleBackNavigation` (line 426) checks `hasContent`
(line 430), which is still `true` because the text/media haven't been cleared. The user
is shown a "Save Draft?" dialog even though the draft was just saved moments ago.

**Fix:**

- Track whether the current content has been saved since the last edit. Add a
  `isDraftDirty` (or `hasUnsavedChanges`) flag to `ComposeState`.
- Set `isDraftDirty: true` when text or media changes (`_onTextChanged`,
  `_onMediaChanged`, etc.).
- Set `isDraftDirty: false` after a successful `DraftSaved` event.
- In `_handleBackNavigation`, check `isDraftDirty` instead of (or in addition to)
  `hasContent`. If content exists but `isDraftDirty` is `false`, skip the dialog and
  pop immediately.

**Files:**

- Edit: `lib/features/compose/bloc/compose_state.dart` — add `isDraftDirty` field
  (default `true` for new compositions, `false` after draft load)
- Edit: `lib/features/compose/bloc/compose_bloc.dart` — set `isDraftDirty: true` in
  `_onTextChanged` (line 62) and media-change handlers; set `isDraftDirty: false` in
  `_onDraftSaved` (line 214) and `_onDraftLoaded` (line 241)
- Edit: `lib/features/compose/presentation/compose_screen.dart` —
  `_handleBackNavigation` (line 426): gate the dialog on `state.isDraftDirty` rather
  than just `hasContent`

## 2. Character Counter — No Initial State

**Status:** Incomplete — counter ring starts empty and invisible until the user types.

**Problem:** `_CharCounter` (compose_screen.dart, line 895) only shows the remaining
character count text when `count > 0` (line 918). On an empty compose screen the user
sees a bare progress ring at 0% with no text — there is no indication of the 300-character
limit. When loading a draft, the counter jumps from nothing to whatever the draft's count
is, which feels jarring.

The progress ring itself also starts as just the background circle with no fill, giving
no visual cue about what it represents.

**Fix:**

- Always show the remaining count text, even when `count == 0`. Remove the `if (count > 0)`
  guard so the counter displays `300` on an empty compose screen.
- This gives users an immediate signal: "you have 300 characters" — matching the behavior
  of the official Bluesky app and Twitter/X composer.

**Files:**

- Edit: `lib/features/compose/presentation/compose_screen.dart` — `_CharCounter.build`
  (line 918): remove the `if (count > 0)` condition so the remaining count is always
  visible

## 3. Composer Layout — Drafts Should Be Inline, Not Full-Screen

**Status:** UX issue — drafts open as a modal bottom sheet that covers the composer.

**Problem:** Tapping the drafts button (line 805) calls `_showDraftsDialog` (line 252),
which opens a `showModalBottomSheet` with a `DraggableScrollableSheet` taking 60–90% of
the screen. This obscures the compose area entirely, breaking the user's context. The
overall composer is also described as "colossal" — the full-screen layout with the modal
drafts on top makes it feel heavy.

The desired behavior is: drafts should appear inline, sharing the screen with the
compose area, and be toggleable open/closed.

**Fix:**

- Replace the `showModalBottomSheet` drafts dialog with an inline, collapsible drafts
  panel that sits below the compose text field (or above the bottom toolbar).
- Use an `AnimatedContainer` or `ExpansionTile`-style widget that expands/collapses
  when the drafts button is toggled.
- When expanded, the drafts panel should take roughly half the available space, with the
  compose text field shrinking to accommodate it. The text field remains visible and
  editable above.
- When collapsed, the panel is fully hidden and the compose area reclaims the space.
- Add a toggle state (e.g. `_showDrafts` boolean in the screen's `State`) controlled by
  the existing drafts `IconButton` (line 804).
- Keep the same drafts list UI (ListTile with content preview, time, delete button, tap
  to load) — just move it from a modal into the inline panel.

**Files:**

- Edit: `lib/features/compose/presentation/compose_screen.dart`:
  - Add `_showDrafts` state variable to `_ComposeScreenState`
  - Replace `_showDraftsDialog()` call on the drafts button (line 805) with a
    `setState(() => _showDrafts = !_showDrafts)` toggle
  - Add an inline drafts panel widget between the text field / media area and the
    bottom toolbar (around line 767), wrapped in an `AnimatedSize` or similar for
    smooth expand/collapse
  - Remove or repurpose `_showDraftsDialog()` (lines 252-374) — extract the list
    content into a reusable `_DraftsPanel` widget used by the inline panel
  - Fire `DraftsRequested` event when the panel is opened (same as current behavior)
