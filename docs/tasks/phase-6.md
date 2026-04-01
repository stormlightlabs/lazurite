---
title: Phase 6 Task Breakdown
updated: 2026-03-31
---

# Phase 6 Milestones

## M25 - Social Graph Visualization

### Core - Graph Data

- [ ] `SocialGraphRepository` - depends on `Bluesky` & `ConstellationClient`
- [ ] `getFollows(did, {limit, cursor})` - wraps `bluesky.graph.getFollows`, returns `({List<ProfileView> profiles, String? cursor})`
- [ ] `getFollowers(did, {limit, cursor})` - wraps `bluesky.graph.getFollowers`, returns same shape
- [ ] `fetchGraphData(did, {maxNodes: 200})` - fetches follows + followers up to cap, computes mutual set by DID intersection, returns `GraphData`
- [ ] `GraphNode` model - `did`, `handle`, `displayName`, `avatarUrl`, `bannerUrl`, `relationship` (enum: mutual/following/follower)
- [ ] `GraphEdge` model - `sourceDid`, `targetDid`, `type` (enum: mutual/follows/followedBy), `weight`
- [ ] `GraphData` model - `centerDid`, `List<GraphNode> nodes`, `List<GraphEdge> edges`

### Core - PDS Resolution

- [ ] `PdsResolver` - resolves DID → PDS host
- [ ] `did:plc` resolution - `GET https://plc.directory/{did}`, parse `service` array for `#atproto_pds` entry, extract host from `serviceEndpoint`
- [ ] `did:web` resolution - `GET https://{identifier}/.well-known/did.json`, same parsing
- [ ] In-memory cache (`Map<String, String>`) for resolved PDS hosts, per session

### Core - Force-Directed Layout Engine

- [ ] `ForceSimulation` class - velocity Verlet integration, configurable parameters
- [ ] Charge repulsion force - Barnes-Hut quadtree approximation for O(n log n)
- [ ] Spring attraction force - edge-based, stronger constant for mutual edges
- [ ] Center gravity - gentle pull toward canvas center to prevent drift
- [ ] Cooling schedule - alpha decay, auto-pause when kinetic energy < threshold
- [ ] `SimulationNode` - position (`Offset`), velocity, pinned flag, reference to `GraphNode`
- [ ] `tick()` method - single simulation step, returns whether simulation is still active

### Cubit

- [ ] `SocialGraphCubit` - `load(did)` fetches graph data, initializes simulation
- [ ] `SocialGraphState` - fields: `status` (loading/loaded/error), `graphData`, `selectedNode`, `simulationActive`
- [ ] `selectNode(did)` - sets selected node for info card display
- [ ] `dismissCard()` - clears selected node
- [ ] `pinNode(did, offset)` / `unpinNode(did)` - for drag interaction

### UI - Graph Canvas

- [ ] `SocialGraphScreen` - route `/social-graph?did={DID}`, `AppBar` + full-bleed canvas
- [ ] `GraphPainter extends CustomPainter` - renders edges (lines, color-coded), nodes (avatar circles with relationship-colored borders)
- [ ] `InteractiveViewer` wrapping `CustomPaint` for pan + pinch-zoom
- [ ] `Ticker`-driven animation loop - calls `ForceSimulation.tick()`, triggers repaint via `notifyListeners`
- [ ] Lazy avatar loading - `ImageProvider` textures, placeholder colored circle until loaded
- [ ] Tap detection - hit-test nodes by distance from touch point, emit `selectNode`
- [ ] Drag detection - `GestureDetector` on nodes for pin/unpin
- [ ] Floating legend row - colored dots: Mutual / Following / Follower
- [ ] Loading state - centered spinner + "Building graph..."
- [ ] Error state - retry button
- [ ] Progressive loading - start rendering when first follows page arrives, add nodes as more pages load

### UI - Info Card Overlay

- [ ] `GraphInfoCard` widget - `Material` card positioned near tapped node (clamped to viewport bounds)
- [ ] Banner image header (120px, gradient fallback)
- [ ] Avatar circle (56px) overlapping banner
- [ ] Display name + handle
- [ ] DID row - monospace, truncated, copy-to-clipboard button
- [ ] PDS host - resolved via `PdsResolver`, loading indicator until resolved
- [ ] "View Profile" `FilledButton` → pop card, navigate to `/profile?did={DID}`
- [ ] Dismiss: tap outside, swipe down, or X button

### UI - Entry Point

- [ ] Profile screen overflow menu - add "Social Graph" entry below "Profile Context"
- [ ] Route: `/social-graph?did={DID}` in `app_router.dart`

### Tests

- [ ] Unit tests: `SocialGraphRepository` - follows/followers fetching, cap enforcement, mutual detection
- [ ] Unit tests: `PdsResolver` - `did:plc` and `did:web` parsing, cache hit, error handling
- [ ] Unit tests: `ForceSimulation` - convergence, node pinning, cooling, edge weight effect
- [ ] Unit tests: `SocialGraphCubit` - state transitions, node selection, progressive loading
- [ ] Widget tests: screen renders graph canvas, legend chips, info card shows on tap with correct fields, "View Profile" navigates, loading/error states
