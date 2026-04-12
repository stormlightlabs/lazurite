---
title: Phase 8 Task Breakdown
updated: 2026-04-11
---

## M27 - Follow Hygiene: Detect & Remove Inactive/Problematic Follows

### Core

#### Models

- [ ] `FollowStatus` enum — `deleted`, `deactivated`, `suspended`, `blockedBy`, `blocking`, `mutualBlock`, `hidden`, `selfFollow`
- [ ] `FollowRecord` model — `uri`, `rkey`, `subjectDid`; extracted from `com.atproto.repo.listRecords` response
- [ ] `ClassifiedFollow` model — `record` (FollowRecord), `handle`, `status` (FollowStatus), `statusLabel`, `selected` (mutable); `Equatable` for state comparison (excluding `selected`)

#### Repository

- [ ] `FollowAuditRepository` — new file `lib/features/profile/data/follow_audit_repository.dart`, depends on authenticated `Bluesky` client
- [ ] `fetchAllFollows(String did)` — paginate `atproto.repo.listRecords(repo: did, collection: 'app.bsky.graph.follow', limit: 100)` with cursor until exhausted, return `List<FollowRecord>`
- [ ] `classifyFollows(List<FollowRecord>, String ownDid)` — batch `actor.getProfiles` (25/batch, 2 concurrent, 500ms inter-group delay), per-DID `getProfile` fallback for missing entries, classify each by `FollowStatus`, return `(List<ClassifiedFollow> results, int failedCount)`
- [ ] `batchUnfollow(List<ClassifiedFollow>)` — extract rkeys, build `applyWrites#delete` operations, chunk into batches of 200, execute sequentially, return count of successfully deleted records
- [ ] Retry logic — on 429 or network error during `getProfiles`/`getProfile`, exponential backoff (1s/2s/4s), max 3 retries per batch

#### Cubit

- [ ] `FollowAuditState` — `status` (initial/fetching/classifying/ready/unfollowing/complete/error), `results`, `totalFollows`, `progress`, `failedProfiles`, `unfollowedCount`, `errorMessage`, `visibleStatuses`
- [ ] `FollowAuditCubit` — depends on `FollowAuditRepository`, authenticated DID
- [ ] `audit()` — orchestrates fetch → classify → ready, emits progress updates during each phase
- [ ] `toggleSelection(int index)` — toggle individual record selection
- [ ] `selectAllByStatus(FollowStatus)` / `deselectAllByStatus(FollowStatus)` — bulk select/deselect by category
- [ ] `toggleVisibility(FollowStatus)` — show/hide category in results list
- [ ] `confirmUnfollow()` — call `batchUnfollow` with selected records, emit unfollowing → complete, clear unfollowed records from results

### UI

#### Follow Audit Screen

- [ ] `FollowAuditScreen` — new file `lib/features/profile/presentation/follow_audit_screen.dart`
- [ ] Header — "Clean Follows" title, subtitle with total follow count
- [ ] Action bar — "Scan" button (initial) → "Unfollow Selected (N)" button (ready), disabled during loading states
- [ ] Linear progress bar — during fetch/classify, shows "Fetching follows: X/Y" or "Classifying: X/Y"
- [ ] Failed profiles warning — amber text below progress bar when `failedProfiles > 0`
- [ ] Results list — checkbox, handle (tappable → navigate to profile via GoRouter), truncated DID, status badge chip. Selected rows get destructive-red background tint
- [ ] Empty state — "No problematic follows found" when audit completes with 0 results
- [ ] Complete state — "Unfollowed N account(s)" after successful batch delete
- [ ] Error state — error message with "Retry" button

#### Filter Controls

- [ ] Responsive layout — horizontal scrollable chip row on narrow screens (`< 600px`), sticky sidebar on wider screens
- [ ] Per-status filter tile — visibility toggle (show/hide rows of that status in list) + "Select All" checkbox
- [ ] Category count badges — show count of results per status category
- [ ] Summary line — "Selected: N/M" count, always visible

#### Navigation & Entry Points

- [ ] Settings screen — new "Account Maintenance" section with "Clean Follows" tile, navigates to `FollowAuditScreen`
- [ ] Profile screen overflow menu — add "Clean Follows" option when viewing own profile, navigates to `FollowAuditScreen`
- [ ] GoRouter route — `/settings/clean-follows`

### Tests

#### Unit Tests — Models

- [ ] `FollowRecord` — construction, rkey extraction from AT URI
- [ ] `ClassifiedFollow` — construction, statusLabel mapping for each `FollowStatus` value
- [ ] `FollowStatus` — verify all enum values exist and labels are correct

#### Unit Tests — Repository

- [ ] `fetchAllFollows` — single page (< 100 records), multi-page pagination (cursor handling), empty follows list
- [ ] `classifyFollows` — deleted account (getProfile returns "not found"), deactivated account, suspended account
- [ ] `classifyFollows` — blocked-by (viewer.blockedBy), blocking (viewer.blocking), mutual block (both), hidden (!hide label), self-follow
- [ ] `classifyFollows` — batch hydration: profiles returned in getProfiles are classified correctly, missing profiles fall through to per-DID lookup
- [ ] `classifyFollows` — partial failure: some batches fail, returns results for successful batches + failedCount
- [ ] `classifyFollows` — rate limit retry: mock 429 response, verify retry with backoff
- [ ] `batchUnfollow` — single batch (< 200 records), multi-batch chunking, empty selection (no-op)
- [ ] `batchUnfollow` — partial failure: first batch succeeds, second fails, returns partial count

#### Unit Tests — Cubit

- [ ] `audit()` — state transitions: initial → fetching → classifying → ready
- [ ] `audit()` — progress updates emitted during fetch and classify phases
- [ ] `audit()` — error during fetch: initial → fetching → error
- [ ] `audit()` — empty results: transitions to ready with empty list
- [ ] `toggleSelection` — toggles selected flag on correct index, emits new state
- [ ] `selectAllByStatus` / `deselectAllByStatus` — selects/deselects all records matching status
- [ ] `toggleVisibility` — adds/removes status from visibleStatuses set
- [ ] `confirmUnfollow` — state transitions: ready → unfollowing → complete, unfollowed records removed from results
- [ ] `confirmUnfollow` — error during unfollow: ready → unfollowing → error with partial count

#### Widget Tests (FollowAuditScreen)

- [ ] initial state renders "Scan" button
- [ ] fetching state shows progress bar with count text
- [ ] ready state renders results list with correct status badges
- [ ] selecting a record changes row background to red tint
- [ ] "Unfollow Selected" button shows correct count and is disabled when nothing selected
- [ ] filter toggles hide/show rows by status
- [ ] "Select All" per category selects all visible records of that status
- [ ] complete state shows "Unfollowed N account(s)"
- [ ] error state shows message and retry button
- [ ] empty results shows "No problematic follows found"
- [ ] tapping handle navigates to profile screen
- [ ] responsive layout: chips on narrow, sidebar on wide

#### Integration Tests

- [ ] End-to-end: scan follows → results displayed → select records → confirm unfollow → success state
