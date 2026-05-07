---
title: App Foundation
updated: 2026-05-07
---

Lazurite's app shell is feature-first Flutter code backed by `flutter_bloc`,
`go_router`, and Drift. Cross-feature concerns live under `lib/core`; feature
modules own their data, state, and presentation code under `lib/features`.

State is modeled with small Bloc or Cubit classes. Presentation widgets render
state and dispatch user intent; they should not own network or persistence
rules. State classes are immutable and use explicit `copyWith` methods. Session
or preference values that must survive app restarts are loaded from Drift rather
than widget state.

## Persistence

Drift is the primary local store. The schema lives in
`lib/core/database/tables.dart` and `lib/core/database/app_database.dart`.
Account, cached profile, cached post, and settings rows form the base local
model. Any user-scoped row must include the active account DID, and repository
queries should filter by that DID. Drift migrations remain mandatory for schema
changes.

The account table stores the DID, handle, and token material needed to restore
the active session. Sensitive values must not be logged. Settings store theme
choice, active account, and later feature preferences.

## Authentication

Production login uses AT Protocol OAuth. Lazurite is a public native client
with a hosted client metadata document and DPoP-bound tokens. The login flow
resolves the user's account authority, sends the user through the system
browser, captures the callback, exchanges the authorization code, and stores
the resulting session for later restore.

DPoP proof generation belongs in the auth layer. Every authenticated request
uses the access token plus a fresh DPoP header. Refresh behavior is owned by
the OAuth client and recovery services, not individual screens.

App-password login exists only for debug paths. It calls
`com.atproto.server.createSession`, stores the returned JWTs, and should remain
guarded by debug flags. App-password sessions do not have the same protocol
coverage as OAuth sessions, so production behavior should assume OAuth.

Logout revokes or discards the active token state, clears the in-memory
authentication state, and returns the user to login. Account switching builds
on the same account table, but the active DID setting decides which session is
currently hydrated.

## Profile Rendering

Profiles are fetched through `app.bsky.actor.getProfile` or batched with
`getProfiles`. The profile UI renders avatar, banner, display name, handle,
description, counts, and any supported extended fields.

Author feeds come from `app.bsky.feed.getAuthorFeed`, paginated with cursors.
The feed renderer consumes hydrated `feedViewPost` values, including embeds,
reply metadata, language tags, and viewer state. The same post-card renderer is
used across later feed, search, saved-post, and list surfaces.

Rich text facets use UTF-8 byte ranges, not Dart UTF-16 indices. Use
`bluesky_text` or existing shared facet helpers to detect and render mentions,
links, and tags. Mentions navigate to profile routes, hashtags navigate to
topic or search routes, and normal links open externally unless a provider-aware
internal route exists.

## Settings And Themes

Settings expose system, light, and dark modes plus named theme palettes. Theme
selection is persisted in Drift and applied through `ThemeMode` at the app
root. New widgets should read theme data through the shared theme extensions in
`lib/core/theme`.

The implemented palette work includes built-in families such as Oxocarbon,
Catppuccin, Nord, and Rose Pine. Each palette maps into Flutter `ThemeData` and
`ColorScheme` objects. Feature code should depend on semantic colors from the
theme, not raw palette constants, unless it is implementing the theme itself.
