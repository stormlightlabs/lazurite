# Testing Patterns

Advanced patterns and techniques for testing Lazurite components. Supplementing the basics at [README.md](./README.md).

## Testing AutoDispose Providers

When testing providers marked with `@riverpod` (which are `autoDispose` by default) or explicitly `.autoDispose`:

**Rule:** Always maintain an active listener using `container.listen()` when testing `autoDispose` providers, especially when awaiting async operations.

**Anti-Pattern:**

```dart
// DON'T: Provider may be disposed immediately if it has no listeners
await container.read(provider.notifier).method();
```

**Correct Pattern:**

```dart
// DO: Keep provider alive
container.listen(provider, (_, _) {});
await container.read(provider.notifier).method();
```

## Handling Async Initialization

Providers that use `Future.microtask` in their `build()` method to trigger side effects can cause unhandled exceptions in tests.

**Solution:**

- Wrap `refresh()` or side-effect calls in `build()` with `.catchError()` or `try/catch`.
- Ensure tests verify behavior when these initial calls fail.

## Async Disposal

If a provider or service requires async cleanup, await it before disposing the container.

```dart
tearDown(() async {
  await container.read(serviceProvider).dispose();
  container.dispose();
});
```

## Fixing Pending Timer Errors

If a test fails with "Timer is still pending after widget tree was disposed":

1. **Flush Widget Tree:** Force a rebuild with a simple widget before the test ends.

   ```dart
   await tester.pumpWidget(const Placeholder());
   ```

2. **Synchronous DB Streams:** When using Drift in tests, ensure streams close synchronously.

   ```dart
   final connection = DatabaseConnection(executor, closeStreamsSynchronously: true);
   ```

3. **Override Background Controllers:** Replace background sync/cleanup controllers with no-ops.

   ```dart
   overrides: [
     timelineCleanupControllerProvider.overrideWith((ref) {}),
   ],
   ```

## Drift Database Testing

**Integration Tests:** Use `NativeDatabase.memory()` to test actual DAO logic.
**Widget Tests:** **ALWAYS** use `MockAppDatabase`. Never use a real database in widget tests to avoid background isolate and timer issues.

## Mocking Streams

**Rule:** Never use `Stream.empty()` for List streams. Use `Stream.value([])` to ensure the first value is emitted immediately. `Stream.empty()` never emits, which can cause `await container.read(provider.future)` to hang indefinitely if the provider waits for the first value.

```dart
// Correct: emits empty list immediately
when(() => mockDao.watchItems()).thenAnswer((_) => Stream.value([]));

// Wrong: never emits, causes test to hang
when(() => mockDao.watchItems()).thenAnswer((_) => Stream.empty());
```

## Widget Test Setup

Use reusable "subject builders" to standardize test environments.

**Reference:** `createSubject` patterns in `test/src/features/` (e.g., `search_screen_test.dart`).

```dart
Widget createSubject({
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(mockDatabase),
      ...overrides,
    ],
    child: const MaterialApp(home: MyScreen()),
  );
}
```

## References

- **Mocks:** `test/helpers/mocks.dart`
- **Pump App Helper:** `test/helpers/pump_app.dart`
- **Database Test Setup:** `test/helpers/test_database.dart`
