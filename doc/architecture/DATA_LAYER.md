# Data Layer Patterns

Patterns for organizing domain models and infrastructure repositories.

## Domain Models

Use Freezed value objects for business entities and DTOs.

**Reference:** `Post` in `lib/src/core/domain/post.dart` (if it exists) or `lib/src/features/feeds/domain/feed_generator.dart`.

Key Rules:

- **Value Objects vs Entities:** Value objects are immutable and identified by contents. Entities have persistent identity (e.g., a `did` or `id`).
- **Multiple Factories:** Use multiple factory constructors for different data sources (API JSON, Database rows).

```dart
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String uri,
    required String cid,
    required Author author,
    required String text,
  }) = _Post;

  const Post._();

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  // Custom factory for mapping from Lexicon/API structures
  factory Post.fromLexicon(Map<String, dynamic> json) {
    // ... logic ...
  }
}
```

## Repository Pattern

Repositories orchestrate between data sources (API, Database/DAO) and the application layer.

**Reference:** `FeedRepository` in `lib/src/features/feeds/infrastructure/feed_repository.dart`

Key Rules:

- Repositories are plain classes, injected via Riverpod providers.
- Transform API responses or database rows into domain models here.
- Never expose DAOs directly to the application layer.
- Log at this level for debugging using the `Logger`.

### Provider Hierarchy

Organize providers in layers to maintain a clear dependency direction: `presentation -> application -> infrastructure -> domain`.

```dart
// Layer 1: Core services (keepAlive)
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

// Layer 2: Repositories (keepAlive, depend on Layer 1)
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) {
  return FeedRepository(
    ref.watch(appDatabaseProvider).feedDao,
    ref.watch(xrpcClientProvider),
  );
}

// Layer 3: Application layer (feature-level)
@riverpod
class FeedNotifier extends _$FeedNotifier {
  @override
  Future<FeedState> build() async {
    final repo = ref.watch(feedRepositoryProvider);
    return repo.initialize();
  }
}
```

## Feature Structure

Maintain a layered organization within each feature directory:

```sh
lib/src/features/feed/
├── domain/              # Value objects, business logic
├── infrastructure/      # Repositories, API clients
├── application/         # Riverpod providers, notifiers
└── presentation/        # UI widgets, screens
```

**Import Rules:**

- Presentation imports application and domain, never infrastructure.
- Application imports infrastructure and domain.
- Infrastructure imports domain only.
- Domain has no internal dependencies.
