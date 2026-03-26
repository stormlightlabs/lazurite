---
title: Phase 5 Spec
updated: 2026-03-25
---

## Feature Parity

Three new endpoint integrations to round out UI coverage.

---

### 1. Starter Pack Search (Search Screen)

**Endpoint:** `GET /xrpc/app.bsky.graph.searchStarterPacks`
**Auth:** Not required

**Request:**

| Param    | Type   | Required | Default | Notes                         |
|----------|--------|----------|---------|-------------------------------|
| `q`      | string | yes      | —       | Lucene-style query            |
| `limit`  | int    | no       | 25      | 1–100                         |
| `cursor` | string | no       | —       | Pagination cursor             |

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

No pagination — returns all suggestions in one response.

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
