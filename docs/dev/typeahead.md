---
title: Typeahead
updated: 2026-05-07
---

Typeahead is a shared actor autocomplete system used by login, search,
jump-to-profile, list member management, and starter pack member management. It
normalizes results from more than one backend so UI code can render one result
model.

## Providers

The official provider calls `app.bsky.actor.searchActorsTypeahead` through the
Bluesky SDK. It requires an authenticated session and returns profile basics,
including viewer data when available.

The community provider calls the waow.tech compatible XRPC endpoint over HTTP.
It does not require authentication, so login can offer suggestions before the
user has a session. It returns a compatible actors array but omits viewer state.
The app adds an `X-Client: lazurite` header and applies local moderation after
parsing.

Both providers normalize into the shared typeahead result model: DID, handle,
optional display name, optional avatar URL, and labels. UI code should not
branch on raw provider response shapes.

## Repository Behavior

`TypeaheadRepository` in `lib/features/typeahead/data/typeahead_repository.dart`
owns provider selection, HTTP calls, SDK calls, parsing, moderation filtering,
and fallback. When the configured provider is official, it delegates to the SDK
and includes moderation-aware request behavior. When the configured provider is
community, it performs the HTTP request, parses JSON, and filters locally.

If the community endpoint fails and an authenticated Bluesky client is
available, the repository can fall back to the official endpoint. Login cannot
use this fallback because there is no session yet. Fallbacks should be logged
with provider and failure reason.

## Settings

The selected provider is stored in settings as `typeahead_provider`. The
default is the official Bluesky provider. Settings expose both official and
community options, with copy that makes the third-party nature of the community
provider clear.

Login overrides the setting and uses the community provider because official
typeahead requires auth. All authenticated surfaces respect the saved setting.

## UI And State

`TypeaheadCubit` owns query changes, debounce, loading, results, and error
state. Consumers should use the shared Cubit or repository instead of calling
search repositories directly for actor autocomplete.

`TypeaheadTextField` in `lib/features/typeahead/presentation/typeahead_text_field.dart`
anchors suggestions below a text field with an overlay. It debounces input,
ignores empty or too-short queries, and updates overlay position with keyboard
and layout changes. Selecting a result fills the field and calls the consumer's
selection callback.

The search screen should keep post search state separate from actor typeahead.
Jump-to-profile, list member add, and starter pack member add use the same
autocomplete path so moderation, rate limiting, and provider choice remain
consistent.

## Limits

Debounce defaults to 300 ms and empty queries return without network calls.
In-flight requests should be canceled or ignored when a newer query starts.

Community responses do not include viewer state, so follow badges or other
viewer-dependent affordances should hide rather than guess. DID entry bypasses
typeahead because typeahead is handle and display-name search.
