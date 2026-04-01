---
title: Phase 6 Spec
updated: 2026-03-31
---

## Social Graph Visualization

A force-directed graph visualization showing a user's social connections. Inspired by [Skircle](https://skircle.me) - lets people explore their network as an interactive tension graph.

### Data Sources

The graph is built from three relationship sets for a target DID:

**Follows (outgoing):** `bluesky.graph.getFollows(actor:, limit:, cursor:)`
→ Paginated `ProfileView[]`. Fetch up to a configurable cap (default: 200) to keep rendering performant.

**Followers (incoming):** `bluesky.graph.getFollowers(actor:, limit:, cursor:)`
→ Paginated `ProfileView[]`. Same cap.

**Mutual detection:** Intersect the two sets by DID. Mutuals get a distinct edge style (thicker, accent-colored).

**Constellation backlinks for extended context:**

- `getDistinct` with `source=app.bsky.graph.block:subject` to identify blocked/blocking edges (rendered as dashed/muted)
- `getBacklinksCount` for aggregate stats shown in the info card

### Graph Model

```dart
GraphNode {
  did: String
  handle: String
  displayName: String?
  avatarUrl: String?
  bannerUrl: String?    // for the detail card
  pdsHost: String       // extracted from DID document or handle resolution
  relationship: enum { mutual, following, follower }
}

GraphEdge {
  source: DID
  target: DID
  type: enum { mutual, follows, followedBy }
  weight: double  // mutual = 1.0, one-way = 0.5
}
```

### Force-Directed Layout

Use a velocity Verlet integration loop on a `CustomPainter` canvas (no external package dependency):

- **Center node:** the target user, pinned at canvas center
- **Charge repulsion:** all nodes repel (Barnes-Hut approximation for O(n log n))
- **Spring attraction:** connected nodes attract along edges; mutuals have stronger spring constant
- **Edge rendering:** straight lines, color-coded by type (mutual = accent, one-way = muted)
- **Node rendering:** circular avatar with border ring colored by relationship type
- **Tick loop:** driven by `Ticker` (vsync), capped at 60fps, with cooling - simulation freezes after convergence

**Interaction:**

- Pan & pinch-zoom via `InteractiveViewer` wrapping the canvas
- Tap node → show user info card (overlay, not navigation)
- Drag node → pin it in place; release to unpin

**Performance constraints:**

- Cap total nodes at ~250 to stay smooth on mid-range devices
- Avatars loaded lazily as `ImageProvider` textures, with placeholder circle until loaded
- Simulation auto-pauses when graph settles (kinetic energy below threshold)

### User Info Card (overlay)

Shown as a `Material` card overlaying the graph canvas when a node is tapped. Positioned near the tapped node (clamped to viewport).

**Layout:**

- Banner image (cover photo) as card header (120px, fallback: gradient)
- Avatar circle overlapping banner bottom-left (56px)
- Display name (bold) + handle (secondary)
- DID (monospace, truncated with copy button)
- PDS host (e.g., `bsky.network`, derived from DID doc `#atproto_pds` service endpoint)
- "View Profile" button → navigates to `/profile?did={DID}`

**Dismiss:** tap outside card, swipe down, or tap X button.

### PDS Resolution

To show the PDS host in the info card, resolve the DID document:

**For `did:plc`:** `GET https://plc.directory/{did}`
→ Response includes `service` array; find entry with `id: "#atproto_pds"`, extract `serviceEndpoint` host.

**For `did:web`:** `GET https://{handle}/.well-known/did.json`
→ Same structure.

Cache resolved PDS hosts in memory (Map<DID, String>) for the session - DID docs rarely change.

### Screen & Navigation

**Route:** `/social-graph?did={DID}`

**Entry point:** New "Social Graph" item in the profile screen's overflow menu, below "Profile Context". Available for all profiles (own and others).

**Screen layout:**

- `AppBar` with title "Social Graph" and handle subtitle
- Full-bleed canvas below
- Floating legend chip row at bottom: colored dots with labels (Mutual / Following / Follower)
- Loading state: centered spinner with "Building graph..." text while fetching follows/followers
- Error state: retry button

**Progressive loading:** Start rendering as soon as first page of follows arrives. Add nodes incrementally as more pages load - the force simulation naturally incorporates new nodes.

### Package Considerations

No external graph package. Implement with:

- `CustomPainter` for rendering
- `GestureDetector` / `InteractiveViewer` for interaction
- `Ticker` for animation loop
- `dart:ui` `Canvas` for drawing circles, lines, images

This avoids dependency risk and gives full control over the mobile-optimized rendering pipeline.
