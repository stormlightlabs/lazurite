---
title: Semantic Search
updated: 2026-05-07
---

Semantic search lets users search saved and liked posts by meaning while
keeping all indexing and query work on device. Drift remains the source of truth
for post content. ObjectBox stores embedding vectors and the metadata needed to
join search results back to Drift rows.

## Storage Model

ObjectBox is the secondary store for vectors. `EmbeddedPost` in
`lib/core/objectbox/embedded_post.dart` records the post URI, active account
DID, source (`saved` or `liked`), indexed text, vector, and embedding timestamp.
The vector uses a 384-dimensional HNSW cosine index.

All queries filter by account DID. Account switching must not query another
account's vector rows. Removing a saved or liked post deletes the matching
embedded row.

Liked posts are cached in Drift so they can participate in local search. The
liked-post table is account-scoped, keyed by post URI, and capped to keep
storage bounded. Sync fetches recent likes until it reaches a known URI or the
configured cap.

## Embedding Runtime

`EmbeddingService` in `lib/core/embedding/embedding_service.dart` loads the
bundled MiniLM INT8 TFLite model and WordPiece vocabulary in a long-lived
isolate. The isolate keeps model work off the UI thread. Each request tokenizes
text, pads or truncates to the model limit, runs inference, normalizes the
vector, and returns it to the caller.

Searchable text comes from the post text, image alt text, and link-card title
or description. If the model or tokenizer cannot load, the service reports
unavailable and UI entry points hide or explain semantic search rather than
throwing.

## Indexing

`SemanticIndexer` in `lib/features/search/data/semantic_indexer.dart` handles
incremental indexing when a post is saved or synced as liked. The indexer
extracts text, embeds it, and upserts the ObjectBox row. Backfill runs when the
feature is enabled for an account or when the user requests reindexing. It
processes posts in batches and reports progress for the settings UI.

Posts on AT Protocol are immutable for this purpose, so embeddings do not need
content refresh. Deletion paths still matter: unsave and unlike must remove
vectors so search results match the user's visible saved and liked sets.

## Query Flow

`SemanticSearchRepository` embeds the query with the same model, runs ObjectBox
nearest-neighbor search, applies account and source filters, then hydrates full
post views from Drift. Results are ordered by vector similarity and shown with a
relevance indicator.

The UI lives as a Search tab on the saved-posts screen. It debounces input,
supports saved/liked/both scopes, reuses post cards, and exposes empty,
unavailable, loading, and no-result states. Settings control feature enablement,
default scope, indexed count, reindexing, and maximum result count.

## Operational Notes

ObjectBox initialization runs once at startup after Drift. The generated
ObjectBox model files must stay committed. Entity changes require code
generation and a review of migration impact on existing vector data.

The feature has clear limits: image meaning is available only through alt text,
search is scoped to one account, results are not BM25 re-ranked, and very old
likes may fall outside the local like cap.
