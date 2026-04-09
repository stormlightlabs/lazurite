---
title: Phase 7 Spec
updated: 2026-04-09
---

## Semantic Search for Saved & Liked Posts

On-device vector search over the user's saved and liked posts.
Posts are embedded at save/like time using an on-device text embedding model, stored in ObjectBox with HNSW indexing, and queried via natural-language input.
The entire pipeline runs locally -- no data leaves the device.

### Why ObjectBox + TFLite (not MediaPipe)

**ObjectBox** (`objectbox` ^5.3.1) is the only Flutter-native vector DB with production-grade HNSW support.
It provides `@HnswIndex` annotations, `nearestNeighborsF32` queries, and composable filters -- exactly what's needed.

**TFLite via `tflite_flutter`** (^0.12.1) is the embedding runtime.
MediaPipe's Flutter package (`mediapipe_text` 0.0.1) requires the Flutter master channel and the experimental `--enable-experiment=native-assets` flag, making it unsuitable for production.
`tflite_flutter` is stable, runs on both iOS and Android, and can load the same TFLite models MediaPipe would use internally.

**Embedding model:** MiniLM-L6-v2 (all-MiniLM-L6-v2), quantized to INT8.
384-dimensional output, ~25 MB model file, ~15ms inference on mid-range devices.
Widely deployed, well-understood, Apache 2.0 licensed. Bundled as a Flutter asset.

> Alternative considered: EmbeddingGemma (768D, ~200 MB). Better quality but 8x the model size -- too large for a bundled mobile asset.
> MiniLM's 384D is sufficient for post-length text and keeps the app install size reasonable.

### Data Flow

```text
Post saved/liked
  → Extract searchable text (post text + alt text from images + link card title/description)
  → Run TFLite inference in background Isolate → Float32List[384]
  → Store in ObjectBox (EmbeddedPost entity with HNSW-indexed vector)

User searches
  → Embed query string via same model → Float32List[384]
  → ObjectBox nearestNeighborsF32(queryVector, maxResults)
  → Map results back to cached/saved posts → display
```

### ObjectBox Entity Model

ObjectBox runs as a **secondary data store** alongside Drift. It stores only embedding vectors and the metadata needed to join back to Drift's `SavedPosts`/cached posts.
Drift remains the source of truth for post content.

```dart
@Entity()
class EmbeddedPost {
  @Id()
  int id = 0;

  /// AT URI of the post (e.g. at://did:plc:xxx/app.bsky.feed.post/yyy)
  @Unique()
  String postUri;

  /// Account DID that saved/liked this post
  String accountDid;

  /// 'saved' or 'liked'
  String source;

  /// Concatenated searchable text at embedding time
  String indexedText;

  /// 384-dimensional embedding vector
  @HnswIndex(dimensions: 384, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  /// When the embedding was generated (for staleness checks)
  @Property(type: PropertyType.dateNano)
  DateTime embeddedAt;
}
```

### Embedding Service

`EmbeddingService` wraps the TFLite interpreter, running in a long-lived background `Isolate` to avoid UI jank.

**Initialization:**

1. App startup → spawn isolate
2. Isolate loads TFLite model from assets (`assets/models/minilm_l6_v2_int8.tflite`)
3. Load tokenizer vocabulary (`assets/models/vocab.txt`) -- WordPiece tokenizer, max 256 tokens
4. Isolate listens on `ReceivePort` for embed requests

**Embedding a post:**

1. Concatenate: `post.text + ' ' + altTexts.join(' ') + ' ' + linkCard?.title + ' ' + linkCard?.description`
2. Tokenize (WordPiece, pad/truncate to 256 tokens)
3. Run interpreter: input `[1, 256]` int32 tensor → output `[1, 384]` float32 tensor
4. L2-normalize the output vector
5. Return `Float32List` to caller via `SendPort`

**Error handling:** If model fails to load (corrupt asset, unsupported device), semantic search degrades gracefully to unavailable. A flag `EmbeddingService.isAvailable` gates all UI entry points.

### Indexing Strategy

**On save/like (incremental):** When a post is saved or liked, immediately queue it for embedding. The `EmbeddingService` isolate processes the queue serially. This keeps indexing latency invisible to the user -- most posts embed in <20ms.

**Backfill (first launch or re-index):** On first enable or after clearing the index, batch-embed all existing saved/liked posts. Process in chunks of 50 with `Future.delayed(Duration.zero)` yielding between chunks to avoid hogging the isolate. Show progress in settings UI ("Indexing: 142/300 posts...").

**Staleness:** Posts are immutable on ATProto, so embeddings never go stale. If a post is un-saved or un-liked, remove its `EmbeddedPost` entry.

**Account isolation:** `EmbeddedPost.accountDid` scopes all queries. On account switch, ObjectBox queries filter by the active account's DID.

### Search UX

**Entry point:** New "Semantic Search" tab in the existing saved posts screen. Two tabs: "All Saved" (existing list) and "Search" (vector search).

**Search tab layout:**

- Text field with hint "Search your saved posts..."
- Debounce: 500ms after typing stops
- Results: list of post cards (reuse existing `PostCard` widget), ordered by cosine similarity
- Each result shows a relevance badge (percentage, derived from `1 - cosineDistance`)
- Empty state when no query entered: "Search your saved and liked posts by meaning, not just keywords"
- No results state: "No similar posts found"
- Max results: 20 (configurable in settings)

**Scope toggle:** Chip row above results: "Saved" / "Liked" / "Both" (default: Both). Implemented as an ObjectBox query condition combined with the vector nearest-neighbor query.

### Liked Posts Integration

Liked posts are not currently persisted locally. To include them in semantic search:

**New Drift table:**

```dart
@DataClassName('LikedPostEntry')
class LikedPosts extends Table {
  IntColumn get id => integer().autoIncrement();
  TextColumn get accountDid => text();
  TextColumn get postUri => text();
  TextColumn get postJson => text();
  DateTimeColumn get likedAt => dateTime().withDefault(currentDateAndTime);

  @override
  List<String> get customConstraints => ['UNIQUE (account_did, post_uri)'];
}
```

**Sync strategy:** Periodic background sync of `bluesky.feed.getActorLikes(actor:, limit:, cursor:)`. Runs on app foreground (if >5 minutes since last sync) and on manual pull-to-refresh. Fetches newest likes until it hits an already-known URI, then stops. Caps at 1000 stored likes per account (evicts oldest on overflow).

This is a **Drift migration** (schema version 15).

### Settings

Under "Search" section in settings:

- **Semantic Search** toggle (default: off) -- enables/disables the feature, triggers backfill on first enable
- **Search scope** -- "Saved only" / "Liked only" / "Both" (default: Both)
- **Index status** -- shows count of indexed posts, "Re-index" button
- **Max results** -- slider, 10-50, default 20

### Package Dependencies

| Package                  | Version | Purpose                                        |
| ------------------------ | ------- | ---------------------------------------------- |
| `objectbox`              | ^5.3.1  | Vector storage + HNSW nearest-neighbor queries |
| `objectbox_flutter_libs` | ^5.3.1  | Platform-specific ObjectBox native libraries   |
| `tflite_flutter`         | ^0.12.1 | On-device TFLite model inference               |

Build tooling: `objectbox_generator` (build_runner) for code generation.

### ObjectBox Integration Notes

ObjectBox requires its own initialization separate from Drift:

```dart
final store = await openStore(directory: join(appDocDir, 'objectbox'));
```

This runs once at app startup (after Drift init). The `Store` instance is provided via the service locator / `RepositoryProvider` tree alongside the existing Drift database.

ObjectBox's generated `objectbox-model.json` and `objectbox.g.dart` must be committed. Run `dart run build_runner build` after entity changes.

### Performance Budget

| Operation                      | Target | Notes                                  |
| ------------------------------ | ------ | -------------------------------------- |
| Model load (cold)              | <500ms | One-time on app start                  |
| Single post embedding          | <20ms  | MiniLM INT8 on mid-range device        |
| Batch embed 100 posts          | <3s    | In background isolate                  |
| Vector query (1000 vectors)    | <5ms   | ObjectBox HNSW                         |
| Vector query (10000 vectors)   | <15ms  | ObjectBox HNSW                         |
| Model asset size               | ~25 MB | INT8 quantized MiniLM-L6-v2            |
| ObjectBox storage (1000 posts) | ~2 MB  | 384 floats x 4 bytes x 1000 + metadata |

### Limitations & Future Work

- **Text-only embeddings.** Image content is captured only via alt text and link card metadata.
  A future phase could add image embeddings (MobileNet V3 + separate HNSW index), but that doubles model size and complexity.
- **No cross-account search.** Each account's embeddings are isolated. A "search all accounts" mode could be added later.
- **No re-ranking.** Results are pure cosine similarity. A future improvement could apply BM25 re-ranking on the top-K results for hybrid search.
  (Highest priority future update)
- **Liked posts sync is incremental, not complete.** The 1000-like cap means very old likes won't be searchable.
  This is a pragmatic trade-off for storage.
