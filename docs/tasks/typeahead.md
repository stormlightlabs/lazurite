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

- [x] Create `lib/features/typeahead/presentation/typeahead_text_field.dart`
- [x] Widget tests: overlay appears on input, results render, tap selects, tap-outside dismisses

## M4 - Login Integration

- [x] Modify `LoginScreen` to use `TypeaheadTextField` for the handle field
- [x] Preserve existing validation (`validator`, `TextInputAction.next`)
- [x] Preserve debug app-password form (unaffected)
- [x] Widget test: login typeahead shows community results, selecting triggers login flow
- [x] Integration test: type handle → see suggestions → tap → OAuth initiates

## M5 - Search Integration

- [x] Inject `TypeaheadRepository` into `SearchBloc` (replace direct `SearchRepository.searchActorsTypeahead` usage)
- [x] Update `SearchBloc._onTypeaheadRequested` to call `TypeaheadRepository.search`
- [x] Map `TypeaheadResult` back to `ProfileViewBasic` for `state.typeaheadActors` compatibility (or migrate state to `TypeaheadResult`)
- [x] Update jump-to-profile dialog to use `TypeaheadCubit` + `TypeaheadTextField`
- [x] Update list member add screen to use `TypeaheadRepository`
- [x] Update starter pack member search to use `TypeaheadRepository`
- [x] Unit tests: `SearchBloc` typeahead delegates to `TypeaheadRepository`
- [x] Widget tests: search typeahead renders results from configured provider

## M5.1 - Runtime Provider Propagation

- [x] Ensure `TypeaheadRepository` resolves provider dynamically so existing consumers pick up `SettingsCubit.typeaheadProvider` changes without app/session rebuild
- [x] Wire authenticated app-scope `TypeaheadRepository` to `SettingsCubit` via resolver callback
- [x] Unit test: same repository instance switches between community and Bluesky backends when provider changes at runtime
