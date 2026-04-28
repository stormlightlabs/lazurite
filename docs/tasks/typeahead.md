# Typeahead Milestones

## M0 - Data Layer

- [x] Create `lib/features/typeahead/data/typeahead_result.dart` - `TypeaheadResult` model (`did`, `handle`, `displayName`, `avatarUrl`, `labels`)
- [x] Create `lib/features/typeahead/data/typeahead_repository.dart`
- [x] Unit tests for `TypeaheadRepository`

## M1 - Settings Integration

- [x] Add `typeahead_provider` column to settings table (Drift migration)
- [x] Add `typeaheadProvider` to `SettingsState`
- [x] Add `setTypeaheadProvider(String)` to `SettingsCubit`
- [x] Settings UI: add "Typeahead Provider" option under a "Search" section
- [x] Unit test: `SettingsCubit` persists and restores typeahead provider
- [x] Widget test: settings screen shows typeahead provider selector

## M2 - TypeaheadCubit

- [x] Create `lib/features/typeahead/cubit/typeahead_cubit.dart`
- [x] Create `lib/features/typeahead/cubit/typeahead_state.dart`
- [x] Unit tests: debounce fires, cancel-on-new-query, empty input handling

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
