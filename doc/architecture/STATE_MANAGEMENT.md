# State Management Patterns

Patterns and conventions for managing application state using Riverpod and Freezed.

## Sealed Classes for State

Use Freezed sealed classes to model complex state with exhaustive pattern matching. This ensures that all possible states are handled at compile-time.

**Reference:** `lib/src/features/auth/domain/auth_state.dart`

Key Rules:

- Always include `loading` and `error` states explicitly.
- Use the `const AuthState._();` constructor to enable custom getters and methods.
- Missing a state branch in a switch expression causes compile errors rather than runtime bugs.

## Pattern Matching

Use native Dart 3 switch expressions instead of Freezed's `.when()` or `.map()` methods (which are deprecated in future versions).

```dart
// Preferred: Native switch expression
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(authNotifierProvider);

  return switch (state) {
    AuthStateLoading() => const CircularProgressIndicator(),
    AuthStateAuthenticated(:final session) => HomeScreen(session: session),
    AuthStateUnauthenticated() => const LoginScreen(),
    AuthStateError(:final error) => ErrorWidget(error),
    AuthStateUnknown() => const SizedBox.shrink(),
  };
}
```

## Notifier Patterns

**Reference:** `AuthNotifier` in `lib/src/features/auth/application/auth_providers.dart`

Key Rules:

- Initialize state immediately in `build()`, even if just `loading()`.
- Never access `state` directly in methods; call methods on the notifier.
- Check `if (!ref.mounted)` before setting state after async operations (though Riverpod handles most of this automatically in `build()`, it's critical in side-effect methods).
- Don't use `.notifier` in providers; access notifier methods through `ref.read()`.

## Stream-Based State

Use Riverpod `StreamProvider` (or class-based `StreamNotifier`) for real-time data from the database or external streams.

**Reference:** `FeedContentNotifier` in `lib/src/features/feeds/application/feed_content_notifier.dart`

```dart
@riverpod
class FeedContentNotifier extends _$FeedContentNotifier {
  @override
  Stream<List<FeedPost>> build(String feedUri) {
    final repository = ref.watch(feedContentRepositoryProvider);

    return repository.watchFeedContent(feedKey: feedUri)
      .map((items) => _applyFilters(items));
  }
}
```

## Provider Keep-Alive Rules

- Use `@Riverpod(keepAlive: true)` for app-level infrastructure (auth, preferences, database).
- Use `@riverpod` (lowercase, auto-dispose) for feature-level state that should be disposed when not in use.

For auto-dispose providers that need conditional persistence, use `ref.keepAlive()` after successful operations:

```dart
@riverpod
Future<Data> fetchData(Ref ref) async {
  final link = ref.keepAlive();

  try {
    final data = await api.fetch();
    return data; // Provider stays alive after success
  } catch (e) {
    link.close(); // Allow disposal on failure
    rethrow;
  }
}
```
