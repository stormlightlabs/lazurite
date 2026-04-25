---
title: Configurable Typeahead
updated: 2026-04-25
---

## Summary

Replace the current single-source typeahead with a configurable system that
supports multiple backends. Two integration points:

1. **Login** - server/handle resolution during OAuth sign-in
2. **Search** - actor autocomplete in search, jump-to-profile, list member
   add, and starter pack member add

## Typeahead backends

### 1. Bluesky Official (default)

Existing endpoint already used by `SearchRepository.searchActorsTypeahead`.

- **Endpoint:** `app.bsky.actor.searchActorsTypeahead`
- **SDK:** `_bluesky.actor.searchActorsTypeahead(q:, limit:)`
- **Auth:** Required (session token)
- **Response:** `List<ProfileViewBasic>` - `did`, `handle`, `displayName`,
  `avatar`, `labels`
- **Rate limit:** Standard Bluesky XRPC limits

### 2. waow.tech Community Typeahead

Community-run drop-in replacement. Useful for unauthenticated contexts (login)
and as a faster/broader index.

- **Endpoint:** `GET https://typeahead.waow.tech/xrpc/app.bsky.actor.searchActorsTypeahead`
- **Params:** `q` (required), `limit` (optional, 1–100, default 10)
- **Headers:** `X-Client: lazurite` (identifies app for traffic stats)
- **Auth:** None required
- **Response:** Same `actors` array shape as Bluesky, minus `viewer` field
- **Rate limit:** 60 req/min per IP, 60s result cache
- **Discovery:** Auto-indexes via Jetstream monitoring; on-demand backfill for
  unknown accounts
- **Moderation:** Respects Bluesky `!hide`/`!takedown`/`!suspend`/`spam` labels;
  filters slur handles

### Response normalisation

Both backends return actors in a compatible shape. The waow.tech response omits
`viewer` (requires auth). Normalise into a common model:

```dart
class TypeaheadResult {
  final String did;
  final String handle;
  final String? displayName;
  final String? avatarUrl;
  final List<Label> labels;
}
```

Parse from `ProfileViewBasic` (Bluesky) or raw JSON (waow.tech) via a factory.

## Configuration

### Settings model

Add a `typeaheadProvider` field to the settings table:

| Key                  | Type   | Values                 | Default   |
| -------------------- | ------ | ---------------------- | --------- |
| `typeahead_provider` | string | `bluesky`, `community` | `bluesky` |

Exposed via `SettingsCubit` as `state.typeaheadProvider`.

### Settings UI

Add a "Typeahead Provider" option in Settings under a "Search" section:

- **Bluesky** - official endpoint, requires login
- **Community (waow.tech)** - faster, works pre-login, community-run

Show a brief description for each option. The community option notes it's a
third-party service.

## TypeaheadRepository

Central abstraction that delegates to the configured backend:

```dart
class TypeaheadRepository {
  TypeaheadRepository({
    required Bluesky? bluesky,
    required String provider,
    ModerationService? moderationService,
  });

  Future<List<TypeaheadResult>> search({
    required String query,
    int limit = 10,
  });
}
```

When `provider == 'bluesky'`:

- Delegates to `bluesky.actor.searchActorsTypeahead`
- Passes moderation headers
- Filters via `ModerationService`

When `provider == 'community'`:

- HTTP GET to `https://typeahead.waow.tech/xrpc/app.bsky.actor.searchActorsTypeahead`
- Uses the existing `http` package (already a dependency)
- Adds `X-Client: lazurite` header
- Parses `actors` array from JSON response
- Applies local moderation filtering (labels are included in response)

### Fallback

If the community endpoint fails (timeout, rate limit, 5xx), fall back to the
Bluesky endpoint when a session is available. Log the fallback via `AppLogger`.

## Integration: Login Screen

### Current state

The login screen has a `TextFormField` for handle/DID entry with no
autocomplete. Users must type their full handle.

### New behaviour

Add typeahead suggestions below the handle field as the user types:

1. User types ≥ 2 characters
2. Debounce 300ms
3. Call `TypeaheadRepository.search` - **always uses community backend** on the
   login screen since no session exists yet (override the setting for this context)
4. Show results in a `ListView` overlay anchored below the text field
5. Each result shows: avatar, display name, handle
6. Tapping a result fills the handle field and triggers the OAuth flow

### Widget: `TypeaheadTextField`

Reusable widget combining `TextFormField` + overlay suggestions:

```dart
class TypeaheadTextField extends StatefulWidget {
  final TextEditingController controller;
  final TypeaheadRepository repository;
  final ValueChanged<TypeaheadResult> onSelected;
  final InputDecoration? decoration;
  final int debounceMs;
  final int minChars;
  final int limit;
}
```

Uses `OverlayEntry` positioned via `LayerLink` + `CompositedTransformFollower`
for correct placement. The overlay follows the text field and adapts to keyboard
presence.

### Login-specific flow

On the login screen, the `TypeaheadRepository` is created without a `Bluesky`
instance and forces `provider: 'community'`. This allows handle discovery
before authentication.

## Integration: Search Screen

### Current state

`SearchBloc` has `TypeaheadRequested` / `TypeaheadResultsLoaded` events that
call `SearchRepository.searchActorsTypeahead` on debounced text input. Results
are stored in `state.typeaheadActors` and shown in the search screen.

### Changes

Replace the direct `SearchRepository.searchActorsTypeahead` call in
`SearchBloc._onTypeaheadRequested` with `TypeaheadRepository.search`. The bloc
receives a `TypeaheadRepository` instead of calling `SearchRepository` for
typeahead.

The typeahead provider setting determines the backend. Users who prefer the
community index get it everywhere (search, jump-to-profile, list member add,
starter pack member add).

### Existing typeahead consumers

All these currently call `SearchRepository.searchActorsTypeahead` and should
migrate to `TypeaheadRepository`:

| Location                           | Context                      |
| ---------------------------------- | ---------------------------- |
| `SearchBloc._onTypeaheadRequested` | Search screen autocomplete   |
| Jump-to-profile dialog             | Search screen FAB            |
| List member add screen             | `searchActorsTypeahead` call |
| Starter pack member search         | Create/edit starter pack     |

## TypeaheadCubit

Shared cubit for typeahead state, usable by any screen:

```dart
class TypeaheadCubit extends Cubit<TypeaheadState> {
  TypeaheadCubit({required TypeaheadRepository repository});

  void onQueryChanged(String query); // debounced
  void clear();
}

class TypeaheadState {
  final List<TypeaheadResult> results;
  final bool isLoading;
  final String? error;
}
```

This replaces the typeahead-related events in `SearchBloc`, keeping search
concerns separate from typeahead concerns.

## Debouncing & rate limiting

- 300ms debounce on text changes (existing pattern in `SearchBloc`)
- Cancel in-flight requests when a new query arrives
- Community backend: 60 req/min limit - debounce alone keeps usage well under
  this (user would need to change input 60 times in a minute past debounce)
- Empty/whitespace queries return empty results immediately (no API call)

## Moderation

Bluesky backend: moderation headers are included; server-side filtering applies.
Results also pass through local `ModerationService.shouldFilterProfileBasicInList`.

Community backend: response includes labels. Apply local moderation filtering
using the same `ModerationService` logic. The community service already hides
`!hide`/`!takedown`/`!suspend` server-side, but local filtering catches
user-specific label preferences.

## Bloc architecture

```text
SettingsCubit.typeaheadProvider
        │
        ▼
TypeaheadRepository ──► Bluesky SDK (authenticated)
        │               HTTP client (community, unauthenticated)
        ▼
TypeaheadCubit ──► TypeaheadState { results, isLoading, error }
        │
        ▼
TypeaheadTextField (Login, Search, Lists, Starter Packs)
```

## Limitations

- Community backend has no `viewer` field - cannot show follow status in
  typeahead results (degrade gracefully: hide follow badge)
- Community backend caches for 60s - very recent handle changes may lag
- Login typeahead cannot fall back to Bluesky (no session)
- DID entry (not handles) bypasses typeahead entirely - typeahead is handle/name
  search only
