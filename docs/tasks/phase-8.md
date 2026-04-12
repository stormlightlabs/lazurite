---
title: Phase 8 Task Breakdown
updated: 2026-04-11
---

## M27 - Follow Hygiene: Detect & Remove Inactive/Problematic Follows

### Core

#### Models

- [x] `FollowStatus` enum — `deleted`, `deactivated`, `suspended`, `blockedBy`, `blocking`, `mutualBlock`, `hidden`, `selfFollow`
- [x] `FollowRecord` model — `uri`, `rkey`, `subjectDid`; extracted from `com.atproto.repo.listRecords` response
- [x] `ClassifiedFollow` model — `record` (FollowRecord), `handle`, `status` (FollowStatus), `statusLabel`, `selected` (mutable); `Equatable` for state comparison (excluding `selected`)

#### Repository

- [x] `FollowAuditRepository` — new file `lib/features/profile/data/follow_audit_repository.dart`, depends on authenticated `Bluesky` client
- [x] `fetchAllFollows(String did)` — paginate `atproto.repo.listRecords(repo: did, collection: 'app.bsky.graph.follow', limit: 100)` with cursor until exhausted, return `List<FollowRecord>`
- [x] `classifyFollows(List<FollowRecord>, String ownDid)` — batch `actor.getProfiles` (25/batch, 2 concurrent, 500ms inter-group delay), per-DID `getProfile` fallback for missing entries, classify each by `FollowStatus`, return `(List<ClassifiedFollow> results, int failedCount)`
- [x] `batchUnfollow(List<ClassifiedFollow>)` — extract rkeys, build `applyWrites#delete` operations, chunk into batches of 200, execute sequentially, return count of successfully deleted records
- [x] Retry logic — on 429 or network error during `getProfiles`/`getProfile`, exponential backoff (1s/2s/4s), max 3 retries per batch

#### Cubit

- [x] `FollowAuditState` — `status` (initial/fetching/classifying/ready/unfollowing/complete/error), `results`, `totalFollows`, `progress`, `failedProfiles`, `unfollowedCount`, `errorMessage`, `visibleStatuses`
- [x] `FollowAuditCubit` — depends on `FollowAuditRepository`, authenticated DID
- [x] `audit()` — orchestrates fetch → classify → ready, emits progress updates during each phase
- [x] `toggleSelection(int index)` — toggle individual record selection
- [x] `selectAllByStatus(FollowStatus)` / `deselectAllByStatus(FollowStatus)` — bulk select/deselect by category
- [x] `toggleVisibility(FollowStatus)` — show/hide category in results list
- [x] `confirmUnfollow()` — call `batchUnfollow` with selected records, emit unfollowing → complete, clear unfollowed records from results

### UI

#### Follow Audit Screen

- [x] `FollowAuditScreen` — new file `lib/features/profile/presentation/follow_audit_screen.dart`
- [x] Header — "Clean Follows" title, subtitle with total follow count
- [x] Action bar — "Scan" button (initial) → "Unfollow Selected (N)" button (ready), disabled during loading states
- [x] Linear progress bar — during fetch/classify, shows "Fetching follows: X/Y" or "Classifying: X/Y"
- [x] Failed profiles warning — amber text below progress bar when `failedProfiles > 0`
- [x] Results list — checkbox, handle (tappable → navigate to profile via GoRouter), truncated DID, status badge chip. Selected rows get destructive-red background tint
- [x] Empty state — "No problematic follows found" when audit completes with 0 results
- [x] Complete state — "Unfollowed N account(s)" after successful batch delete
- [x] Error state — error message with "Retry" button

#### Filter Controls

- [x] Responsive layout — horizontal scrollable chip row on narrow screens (`< 600px`), sticky sidebar on wider screens
- [x] Per-status filter tile — visibility toggle (show/hide rows of that status in list) + "Select All" checkbox
- [x] Category count badges — show count of results per status category
- [x] Summary line — "Selected: N/M" count, always visible

#### Navigation & Entry Points

- [x] Settings screen — new "Account Maintenance" section with "Clean Follows" tile, navigates to `FollowAuditScreen`
- [x] Profile screen overflow menu — add "Clean Follows" option when viewing own profile, navigates to `FollowAuditScreen`
- [x] GoRouter route — `/settings/clean-follows`

### Tests

#### Unit Tests — Models

- [x] `FollowRecord` — construction, rkey extraction from AT URI
- [x] `ClassifiedFollow` — construction, statusLabel mapping for each `FollowStatus` value
- [x] `FollowStatus` — verify all enum values exist and labels are correct

#### Unit Tests — Repository

- [x] `fetchAllFollows` — single page (< 100 records), multi-page pagination (cursor handling), empty follows list
- [x] `classifyFollows` — deleted account (getProfile returns "not found"), deactivated account, suspended account
- [x] `classifyFollows` — blocked-by (viewer.blockedBy), blocking (viewer.blocking), mutual block (both), hidden (!hide label), self-follow
- [x] `classifyFollows` — batch hydration: profiles returned in getProfiles are classified correctly, missing profiles fall through to per-DID lookup
- [x] `classifyFollows` — partial failure: some batches fail, returns results for successful batches + failedCount
- [x] `classifyFollows` — rate limit retry: mock 429 response, verify retry with backoff
- [x] `batchUnfollow` — single batch (< 200 records), multi-batch chunking, empty selection (no-op)
- [x] `batchUnfollow` — partial failure: first batch succeeds, second fails, returns partial count

#### Unit Tests — Cubit

- [x] `audit()` — state transitions: initial → fetching → classifying → ready
- [x] `audit()` — progress updates emitted during fetch and classify phases
- [x] `audit()` — error during fetch: initial → fetching → error
- [x] `audit()` — empty results: transitions to ready with empty list
- [x] `toggleSelection` — toggles selected flag on correct index, emits new state
- [x] `selectAllByStatus` / `deselectAllByStatus` — selects/deselects all records matching status
- [x] `toggleVisibility` — adds/removes status from visibleStatuses set
- [x] `confirmUnfollow` — state transitions: ready → unfollowing → complete, unfollowed records removed from results
- [x] `confirmUnfollow` — error during unfollow: ready → unfollowing → error with partial count

#### Widget Tests (FollowAuditScreen)

- [x] initial state renders "Scan" button
- [x] fetching state shows progress bar with count text
- [x] ready state renders results list with correct status badges
- [x] selecting a record changes row background to red tint
- [x] "Unfollow Selected" button shows correct count and is disabled when nothing selected
- [x] filter toggles hide/show rows by status
- [x] "Select All" per category selects all visible records of that status
- [x] complete state shows "Unfollowed N account(s)"
- [x] error state shows message and retry button
- [x] empty results shows "No problematic follows found"
- [x] tapping handle navigates to profile screen
- [x] responsive layout: chips on narrow, sidebar on wide

#### Integration Tests

- [x] End-to-end: scan follows → results displayed → select records → confirm unfollow → success state
