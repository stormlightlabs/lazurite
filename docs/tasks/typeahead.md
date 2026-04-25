# Typeahead Milestones

## M0 - Data Layer

- [ ] Create `lib/features/typeahead/data/typeahead_result.dart` - `TypeaheadResult` model (`did`, `handle`, `displayName`, `avatarUrl`, `labels`)
  - Factory `fromProfileViewBasic` for Bluesky backend
  - Factory `fromJson` for community backend raw JSON
- [ ] Create `lib/features/typeahead/data/typeahead_repository.dart`
  - Constructor takes optional `Bluesky`, required `provider` string, optional `ModerationService`
  - `search(query, limit)` dispatches to Bluesky SDK or HTTP based on provider
  - Bluesky path: `bluesky.actor.searchActorsTypeahead(q:, limit:)` + moderation headers + filtering
  - Community path: HTTP GET to `https://typeahead.waow.tech/xrpc/app.bsky.actor.searchActorsTypeahead?q=&limit=` with `X-Client: lazurite` header
  - Fallback: community failure → Bluesky endpoint (when session available), log via `AppLogger`
- [ ] Unit tests for `TypeaheadRepository`
  - Bluesky provider delegates to SDK, applies moderation filtering
  - Community provider makes HTTP request, parses JSON, applies local moderation
  - Fallback triggers on community error when Bluesky available
  - Fallback does not trigger when no session (login context)

## M1 - Settings Integration

- [ ] Add `typeahead_provider` column to settings table (Drift migration)
  - Type: text, default: `'bluesky'`, allowed: `'bluesky'` | `'community'`
- [ ] Add `typeaheadProvider` to `SettingsState`
- [ ] Add `setTypeaheadProvider(String)` to `SettingsCubit`
- [ ] Settings UI: add "Typeahead Provider" option under a "Search" section
  - Radio/segmented control: Bluesky / Community (waow.tech)
  - Brief description for each, note community is third-party
- [ ] Unit test: `SettingsCubit` persists and restores typeahead provider
- [ ] Widget test: settings screen shows typeahead provider selector

## M2 - TypeaheadCubit

- [ ] Create `lib/features/typeahead/cubit/typeahead_cubit.dart`
- [ ] Create `lib/features/typeahead/cubit/typeahead_state.dart`
  - State: `results`, `isLoading`, `error`
  - Methods: `onQueryChanged(String)` (300ms debounce), `clear()`
  - Cancel in-flight on new query
  - Empty/whitespace → emit empty results immediately
- [ ] Unit tests: debounce fires, cancel-on-new-query, empty input handling

## M3 - TypeaheadTextField Widget

- [ ] Create `lib/features/typeahead/presentation/typeahead_text_field.dart`
  - Wraps `TextFormField` + `OverlayEntry` for suggestions dropdown
  - Uses `LayerLink` + `CompositedTransformFollower` for positioning
  - Props: `controller`, `repository`, `onSelected`, `decoration`, `debounceMs`, `minChars`, `limit`
  - Each result row: avatar (CircleAvatar), display name, @handle
  - Keyboard-aware: overlay repositions when keyboard shows/hides
  - Tap result → calls `onSelected`, clears overlay
  - Tap outside → dismisses overlay
- [ ] Widget tests: overlay appears on input, results render, tap selects, tap-outside dismisses

## M4 - Login Integration

- [ ] Modify `LoginScreen` to use `TypeaheadTextField` for the handle field
  - Create `TypeaheadRepository` without `Bluesky`, force `provider: 'community'`
  - `onSelected` fills handle controller + triggers `_onOAuthLogin`
  - `minChars: 2`, `debounceMs: 300`, `limit: 8`
- [ ] Preserve existing validation (`validator`, `TextInputAction.next`)
- [ ] Preserve debug app-password form (unaffected)
- [ ] Widget test: login typeahead shows community results, selecting triggers login flow
- [ ] Integration test: type handle → see suggestions → tap → OAuth initiates

## M5 - Search Integration

- [ ] Inject `TypeaheadRepository` into `SearchBloc` (replace direct `SearchRepository.searchActorsTypeahead` usage)
- [ ] Update `SearchBloc._onTypeaheadRequested` to call `TypeaheadRepository.search`
- [ ] Map `TypeaheadResult` back to `ProfileViewBasic` for `state.typeaheadActors` compatibility (or migrate state to `TypeaheadResult`)
- [ ] Update jump-to-profile dialog to use `TypeaheadCubit` + `TypeaheadTextField`
- [ ] Update list member add screen to use `TypeaheadRepository`
- [ ] Update starter pack member search to use `TypeaheadRepository`
- [ ] Unit tests: `SearchBloc` typeahead delegates to `TypeaheadRepository`
- [ ] Widget tests: search typeahead renders results from configured provider

## M6 - Polish & Validation

- [ ] Verify rate limiting: 300ms debounce keeps community usage well under 60 req/min
- [ ] Graceful degradation: community results without `viewer` → hide follow badge
- [ ] Error handling: network timeout → show inline error, not crash
- [ ] `flutter analyze` clean
- [ ] Full test suite passes
