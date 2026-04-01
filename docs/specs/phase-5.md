---
title: Phase 5 Spec
updated: 2026-03-31
---

## Feature Parity

Three new endpoint integrations to round out UI coverage, plus two Constellation-powered features.

---

### 1. Starter Pack Search (Search Screen)

**Endpoint:** `GET /xrpc/app.bsky.graph.searchStarterPacks`
**Auth:** Not required

**Request:**

| Param    | Type   | Required | Default | Notes                         |
|----------|--------|----------|---------|-------------------------------|
| `q`      | string | yes      | -       | Lucene-style query            |
| `limit`  | int    | no       | 25      | 1–100                         |
| `cursor` | string | no       | -       | Pagination cursor             |

**Response:**

```json
{
  "cursor": "string?",
  "starterPacks": "StarterPackViewBasic[]"
}
```

`StarterPackViewBasic` includes: `uri`, `cid`, `record`, `creator` (ProfileViewBasic),
`listItemCount?`, `joinedWeekCount?`, `joinedAllTimeCount?`, `labels?`, `indexedAt`.

**SDK:** `bluesky.graph.searchStarterPacks(q:, limit:, cursor:)`
→ `XRPCResponse<GraphSearchStarterPacksOutput>`

**UI:** Add a third "Starter Packs" tab to the search screen alongside Posts and People.
Tapping a result navigates to the existing starter pack detail screen. Infinite scroll
pagination via cursor. Reuse the existing `StarterPackViewBasic` tile pattern from
the profile starter packs tab.

---

### 2. Suggested Follows (Profile Screen)

**Endpoint:** `GET /xrpc/app.bsky.graph.getSuggestedFollowsByActor`
**Auth:** Not required

**Request:**

| Param   | Type   | Required | Notes             |
|---------|--------|----------|-------------------|
| `actor` | string | yes      | DID or handle     |

**Response:**

```json
{
  "suggestions": "ProfileView[]",
  "isFallback": "bool (default false)",
  "recIdStr": "string?"
}
```

No pagination - returns all suggestions in one response.

**SDK:** `bluesky.graph.getSuggestedFollowsByActor(actor:)`
→ `XRPCResponse<GraphGetSuggestedFollowsByActorOutput>`

**UI:** New "Suggested Follows" entry in the profile screen's overflow (more options)
bottom sheet. Opens a draggable scrollable sheet listing `ProfileView` tiles with
follow/unfollow buttons. Each tile navigates to the user's profile on tap. Show empty
state if `suggestions` is empty. Hide the menu entry when viewing own profile.

---

### 3. Video Upload Limits (Settings Screen)

**Endpoint:** `GET /xrpc/app.bsky.video.getUploadLimits`
**Auth:** Required

**Request:** None

**Response:**

```json
{
  "canUpload": "bool",
  "remainingDailyVideos": "int?",
  "remainingDailyBytes": "int?",
  "message": "string?",
  "error": "string?"
}
```

**SDK:** `bluesky.video.getUploadLimits()`
→ `XRPCResponse<VideoGetUploadLimitsOutput>`

**UI:** New tile in the settings screen's Account section showing daily video upload
quota. Display remaining video count and remaining bytes (formatted as MB/GB).
Show `canUpload` status and any server `message`. Fetch on screen load; show
loading indicator while fetching. If the endpoint returns an error or `canUpload`
is false, show the reason.

---

### 4. Profile Context (Constellation)

Social context for any account powered by [Constellation](https://constellation.microcosm.blue/) - a public AT Protocol backlink index. No auth required; only a `User-Agent` header.

**Design philosophy** (carried from lazurite-desktop diagnostics):

- Inform, don't alarm. Present data neutrally.
- No composite risk scores. Show the data; let the user interpret it.
- Context over counts. Prefer showing _what kind_ of lists over _how many_.
- Respect the viewed account. Default to aggregate summaries; expand to specifics on request.

#### Constellation Client

A thin HTTP client targeting a configurable Constellation instance (default: `https://constellation.microcosm.blue`). User-configurable via Settings to support self-hosted instances. Timeout: 10 seconds.

All endpoints use XRPC format at `{base}/xrpc/{endpoint}` with query parameters.

#### 4a. Blocked By (incoming blocks)

**Endpoint:** `GET /xrpc/blue.microcosm.links.getBacklinksCount`
**Purpose:** Count of accounts that have blocked this user.

| Param    | Type   | Required | Notes                              |
|----------|--------|----------|------------------------------------|
| `subject`| string | yes      | Target DID                         |
| `source` | string | yes      | `app.bsky.graph.block:subject`     |

**Response:** `{ "total": int }`

**Detail list endpoint:** `GET /xrpc/blue.microcosm.links.getDistinct`

| Param    | Type   | Required | Default | Notes                              |
|----------|--------|----------|---------|------------------------------------|
| `subject`| string | yes      | -       | Target DID                         |
| `source` | string | yes      | -       | `app.bsky.graph.block:subject`     |
| `limit`  | int    | no       | 16      | Max 100                            |
| `cursor` | string | no       | -       | Pagination cursor                  |

**Response:** `{ "total": int, "dids": string[], "cursor": string? }`

Returned DIDs are hydrated via `bluesky.actor.getProfiles(actors:)` (batch, max 25 per call) to show profile cards.

#### 4b. Users Blocked (outgoing blocks)

**Endpoint:** `GET /xrpc/com.atproto.repo.listRecords` (AT Protocol, not Constellation)

| Param       | Type   | Required | Default | Notes                         |
|-------------|--------|----------|---------|-------------------------------|
| `repo`      | string | yes      | -       | Actor DID                     |
| `collection`| string | yes      | -       | `app.bsky.graph.block`        |
| `limit`     | int    | no       | 50      | Max 100                       |
| `cursor`    | string | no       | -       | Pagination cursor             |

**Response:** `{ "records": Record[], "cursor": string? }`

Each record's `value.subject` is the blocked DID. Hydrate via `getProfiles`.

**Note:** Outgoing blocks are only readable from the actor's own repo. For other users' profiles, this tab shows only the count from the actor's public repo listing (if accessible) or is hidden entirely if the repo restricts reads.

#### 4c. Lists On

**Endpoint:** `GET /xrpc/blue.microcosm.links.getBacklinks`

| Param    | Type   | Required | Default | Notes                                   |
|----------|--------|----------|---------|-----------------------------------------|
| `subject`| string | yes      | -       | Target DID                              |
| `source` | string | yes      | -       | `app.bsky.graph.listitem:subject`       |
| `limit`  | int    | no       | 16      | Max 100                                 |
| `cursor` | string | no       | -       | Pagination cursor                       |

**Response:**

```json
{
  "total": "int",
  "linking_records": [{ "did": "string", "collection": "string", "rkey": "string" }],
  "cursor": "string?"
}
```

Each backlink record represents a list item. The owning list AT-URI is derived as `at://{record.did}/app.bsky.graph.list/{rkey-of-list}`. Since backlinks only give us the listitem record, we need to resolve the parent list. Two approaches:

1. **getManyToMany** (preferred): `GET /xrpc/blue.microcosm.links.getManyToMany` with `source=app.bsky.graph.listitem:subject` and `pathToOther=list` returns items grouped by their parent list URI. Each item has `otherSubject` (the list AT-URI).
2. **Fallback**: fetch each listitem record via `com.atproto.repo.getRecord` to read its `list` field, then hydrate lists via `bluesky.graph.getList`.

Hydrate list metadata via `bluesky.graph.getList(list:)` to show name, purpose, owner, member count.

#### Profile Context UI

**Entry point:** New "Context" item in the profile screen's overflow menu (PopupMenuButton / three-dot menu). Navigates to a dedicated full screen - not a tab on the profile, since this data is sought intentionally, not browsed casually.

**Route:** `/profile-context?did={DID}`

**Screen layout:**

- `AppBar` with title "Profile Context" and the user's handle as subtitle
- Three-tab `TabBar`: **Blocked By** | **Blocking** | **Lists**
- Each tab is a paginated list with pull-to-refresh

**Blocked By tab:**

- Header row: total count (from `getBacklinksCount`) displayed prominently
- "Show accounts" expand button - on tap, fetches DIDs via `getDistinct` and hydrates profiles
- Profile tiles: avatar, display name, handle. Tap → navigate to profile
- Pagination via cursor (infinite scroll)
- Contextualizing note: _"Blocks are a normal part of social media. This data is public on the AT Protocol."_

**Blocking tab:**

- Same layout as Blocked By but sourced from `listRecords`
- Only available when viewing own profile or if the repo is publicly readable
- When unavailable: show explanatory text

**Lists tab:**

- List cards: name, owner handle, purpose badge (curate/modlist/reference), member count, description snippet
- Grouped by purpose (curation first, then moderation, then reference)
- Tap → navigate to list detail screen (`/list?uri=`)
- Pagination via cursor

**States:**

- Loading: skeleton shimmer matching card dimensions
- Empty: per-tab contextual empty state (e.g., "Not on any lists" / "No blocks found")
- Error: inline retry button per tab, not full-screen error
