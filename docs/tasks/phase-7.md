---
title: Phase 7 Task Breakdown
updated: 2026-04-09
---

# Phase 7 Milestones

## M26 - Semantic Search for Saved & Liked Posts

### Core

#### ObjectBox Setup

- [x] Add `objectbox`, `objectbox_flutter_libs` to `pubspec.yaml`; add `objectbox_generator` to dev deps
- [x] `EmbeddedPost` entity - `postUri` (unique), `accountDid`, `source` (saved/liked), `indexedText`, `embedding` (384D float vector, HNSW cosine index), `embeddedAt`
- [x] Run `build_runner` to generate `objectbox.g.dart` and `objectbox-model.json`
- [x] `ObjectBoxStore` singleton - `openStore()` at app startup (after Drift init), expose via `RepositoryProvider`
- [x] `EmbeddingRepository` - CRUD operations on `EmbeddedPost`: `upsert`, `deleteByUri`, `queryByAccount`, `countByAccount`

#### TFLite Embedding Service

- [x] Add `tflite_flutter` to `pubspec.yaml`
- [x] Bundle `minilm_l6_v2_int8.tflite` and `vocab.txt` as Flutter assets
- [x] `WordPieceTokenizer` - load vocab, tokenize text, pad/truncate to 256 tokens, return `List<int>`
- [x] `EmbeddingService` - long-lived background `Isolate` with `ReceivePort`/`SendPort` message passing
- [x] `EmbeddingService.initialize()` - spawn isolate, load TFLite model + tokenizer in isolate
- [x] `EmbeddingService.embed(String text)` - send text to isolate, receive `Float32List[384]`, L2-normalize
- [x] `EmbeddingService.isAvailable` - flag gating UI entry points, false if model fails to load
- [x] `EmbeddingService.dispose()` - close isolate and interpreter
- [x] `PostTextExtractor` - concatenate post text + image alt texts + link card title/description into a single searchable string

#### Liked Posts Sync

- [x] `LikedPosts` Drift table - `id`, `accountDid`, `postUri`, `postJson`, `likedAt`; unique constraint on `(account_did, post_uri)`
- [x] Drift migration v15 - add `liked_posts` table
- [x] `LikedPostsRepository` - `syncLikes(accountDid)`: call `bluesky.feed.getActorLikes(actor:, limit:100, cursor:)`, paginate until hitting known URI or 1000 cap, upsert new entries
- [x] `LikedPostsRepository.getLikedPosts(accountDid, {limit, offset})` - paginated query
- [x] `LikedPostsRepository.removeLike(accountDid, postUri)` - delete entry
- [x] Eviction: drop oldest entries when count exceeds 1000 per account
- [x] Documentation update: move development information from README.md to a top-level DEVELOPMENT.md.
  Should be updated to reflect new architecture and patterns.

#### Indexing Pipeline

- [x] `SemanticIndexer` - orchestrates embedding + storage for new posts
- [x] `indexPost(postUri, postJson, accountDid, source)` - extract text, embed, upsert `EmbeddedPost`
- [x] `removePost(postUri)` - delete `EmbeddedPost` entry
- [x] `backfill(accountDid)` - batch-embed all un-indexed saved + liked posts, chunks of 50, yield between chunks
- [x] `backfillProgress` stream - emits `(int completed, int total)` for UI progress display
- [x] Hook into `SavedPostsRepository.savePost()` - queue new save for indexing
- [x] Hook into `LikedPostsRepository.syncLikes()` - queue newly synced likes for indexing
- [x] Hook into unsave/unlike - remove from `EmbeddedPost`

#### Vector Search

- [x] `SemanticSearchRepository` - depends on `EmbeddingService`, `EmbeddingRepository`
- [x] `search(query, accountDid, {source, maxResults})` - embed query, run `nearestNeighborsF32`, filter by `accountDid` and optional `source`, return `List<SemanticSearchResult>`
- [x] `SemanticSearchResult` model - `postUri`, `score` (cosine similarity as percentage), `source` (saved/liked)
- [x] Join results back to Drift `SavedPosts`/`LikedPosts` to hydrate full post JSON for display

### Cubit

- [x] `SemanticSearchCubit` - `search(query)` with 500ms debounce, `setScope(source)`, `clearResults()`
- [x] `SemanticSearchState` - `status` (initial/searching/loaded/error/unavailable), `results`, `query`, `scope` (saved/liked/both)
- [x] `LikedPostsSyncCubit` - `sync()` triggers like sync, exposes sync progress
- [x] `SemanticIndexCubit` - exposes `backfillProgress`, `indexedCount`, `reindex()` action

### UI

#### Semantic Search Tab

- [ ] Saved posts screen - add "Search" tab alongside existing "All Saved" tab
- [ ] Search text field with hint "Search your saved posts..."
- [ ] Scope toggle chips: "Saved" / "Liked" / "Both" (default: Both)
- [ ] Results list - reuse `PostCard`, ordered by similarity score
- [ ] Relevance badge on each result (percentage)
- [ ] Empty state (no query): "Search your saved and liked posts by meaning, not just keywords"
- [ ] No results state: "No similar posts found"
- [ ] Unavailable state: shown when `EmbeddingService.isAvailable` is false, with explanation

#### Settings

- [ ] Settings screen - new "Search" section
- [ ] "Semantic Search" toggle (default: off) - enables feature, triggers backfill on first enable
- [ ] "Search scope" dropdown - Saved only / Liked only / Both
- [ ] "Index status" tile - shows indexed post count, "Re-index" button
- [ ] "Max results" slider - 10 to 50, default 20
- [ ] Backfill progress indicator - "Indexing: 142/300 posts..." shown during backfill

### Tests

- [ ] Unit tests: `WordPieceTokenizer` - tokenization, padding, truncation, edge cases (empty string, very long text)
- [ ] Unit tests: `EmbeddingService` - initialization, embed returns correct dimensions, L2 normalization, dispose cleanup
- [ ] Unit tests: `PostTextExtractor` - text concatenation from various post shapes (text-only, images with alt, link cards, combinations)
- [ ] Unit tests: `EmbeddingRepository` - upsert, delete, query by account, count
- [ ] Unit tests: `LikedPostsRepository` - sync pagination, dedup on known URI, 1000-cap eviction
- [ ] Unit tests: `SemanticIndexer` - index/remove/backfill, progress stream, integration with save/like hooks
- [ ] Unit tests: `SemanticSearchRepository` - search returns scored results, scope filtering, account isolation
- [ ] Unit tests: `SemanticSearchCubit` - debounce, state transitions, scope changes
- [ ] Unit tests: `SemanticIndexCubit` - backfill progress, reindex trigger
- [ ] Widget tests: search tab renders, query produces results, scope chips filter, relevance badges display, empty/no-results/unavailable states
- [ ] Widget tests: settings section renders, toggle enables/disables, progress indicator during backfill, re-index button triggers reindex
- [ ] Integration test: save a post → verify it appears in semantic search results for a relevant query
