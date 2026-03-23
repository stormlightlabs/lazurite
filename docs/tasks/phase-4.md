# Phase 4 Milestones

## M12 — Direct Messages

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

## M13 — Media Playback & Download

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

## M14 — Account Switching

- [x] `AccountSwitcherCubit` exposing account list and active DID
- [x] Account switcher bottom sheet UI — list accounts with avatars and handles
- [x] Store `active_account_did` in Drift `settings` table
- [x] Drift migration: add `account_did` column to `cached_posts` if not present
- [x] All user-scoped queries filter by active account DID
- [x] Broadcast `AccountSwitched` event to all Blocs on switch
- [x] "Add Account" button triggers OAuth flow, inserts new `accounts` row
- [x] Silent token refresh on account switch; navigate to login on failure

## M15 — Offline Reading & Network Resilience

- [x] `ConnectivityCubit` via **connectivity_plus** — expose network state stream
- [ ] Cache last-fetched feed page as serialised JSON in Drift
- [ ] Display cached data immediately on launch, refresh in background
- [ ] "You're offline" banner when connectivity is lost
- [ ] Disable network-dependent actions (compose, like, repost, follow) when offline with tooltip
- [ ] Notifications and DM screens show "No connection" empty state when offline with no cache

## M16 — Jump to Profile

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

## M17 — Labelers & Content Moderation

Completed [2026-03-21](../../CHANGELOG.md#2026-03-21)

## M18 — Lists

Completed [2026-03-21](../../CHANGELOG.md#2026-03-21)

## M19 — Starter Packs

Completed [2026-03-22](../../CHANGELOG.md#2026-03-22)
