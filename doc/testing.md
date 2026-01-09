# Testing

## Running Tests

- `just check` - Run format, lint, and test
    - `just test` - Run tests with 60s timeout and verbose output
- `just test-quiet` - Run tests with 30s timeout and quiet output to view errors &
  identify hanging tests

## Patterns

### Avoiding Pending Timers

The most common test failure is "A Timer is still pending even after the widget tree was disposed."
This happens when Drift database streams aren't properly mocked in widget tests.

**Solution:** Override providers that create database streams with mocks returning `Stream.value([])`.

### Testing AutoDispose Providers

When testing providers marked with `@riverpod` (which are `autoDispose` by default) or explicitly `.autoDispose`:

**Rule:** Always maintain an active listener using `container.listen()` when testing `autoDispose` providers, especially when awaiting async operations.

**Anti-Pattern:**

```dart
// DON'T: Provider may be disposed immediately if it has no listeners
await container.read(provider.notifier).method();
```

**Correct Pattern:**

```dart
// D0: Keep provider alive
container.listen(provider, (_, _) {});
await container.read(provider.notifier).method();
```

### Handling Async Initialization

Providers that use `Future.microtask` in their `build()` method to trigger side effects (like fetching data) can cause unhandled exceptions in tests if not handled properly.

**Risk:** If the microtask fails (e.g., initial fetch fails), the error might be unhandled and crash the test process.

**Solution:**

- Wrap `refresh()` calls in `build()` with `.catchError()` or `try/catch`.
- Ensure tests verify the behavior when these initial calls fail.

### Mocking Streams

**Rule:** Never use `Stream.empty()` for List streams. Use `Stream.value([])` to ensure the first value is emitted immediately. `Stream.empty()` never emits, which can cause `await container.read(provider.future)` to hang indefinitely if the provider waits for the first value.

### By Type

#### Widget Tests with Database Streams

**Reference:** `features/search/search_screen_test.dart`

Pattern:

- Create `createSubject()` function with `ProviderScope` and overrides
- Mock repository to return `Stream.value([])` for immediate completion
- Use `pumpWidget()` then `pump()` to process async operations
- Don't use `pumpApp()` helper without proper overrides

#### App/Router Tests

**Reference:** `app/router_test.dart`

Pattern:

- Override ALL providers that screens might use during navigation
- Mock repositories in `setUp()` with immediate streams
- Create custom notifiers returning `Stream.value([])` for providers
- Always close database in `tearDown()`

Critical: When testing navigation to SearchScreen, always mock `searchRepositoryProvider`.

#### Repository Tests

**Reference:** `features/timeline/infrastructure/timeline_repository_test.dart`

Pattern:

- Mock DAO and external clients
- Verify repository transforms data correctly
- Use `.first` on streams to get current value

#### DAO Tests

**Reference:** `infrastructure/db/daos/timeline_dao_test.dart`

Pattern:

- Use `NativeDatabase.memory()` in `setUp()`
- Always close database in `tearDown()`
- Test actual database operations, not mocks
- Use `.first` on watch streams

#### Stream Provider Tests

**Reference:** `features/settings/application/settings_providers_test.dart`

Pattern:

- Use `container.listen()` instead of `await container.read(...).future`
- Avoids "provider was disposed during loading state" errors
- Verify repository method calls with mocktail

Example:

```dart
test('provider calls repository watch method', () {
  const expected = SomeData(...);
  when(() => mockRepository.watchSomeData())
      .thenAnswer((_) => Stream.value(expected));

  container.listen(someDataProvider, (prev, next) {});

  verify(() => mockRepository.watchSomeData()).called(1);
});
```

Critical: Don't use `await container.read(provider.future)` in tests where the container
is disposed in `tearDown()`, as the provider may be disposed before the future completes.

## Pitfalls

1. **Forgetting to override providers** - Any screen with database streams needs mocked providers
2. **Not closing databases** - Always close in `tearDown()` to prevent resource leaks
3. **Using `Stream.empty()`** - Use `Stream.value([])` to emit an empty list
4. **Missing navigation overrides** - Router tests must mock providers for all navigable screens
5. **Testing stream providers with `.future`** - Use `container.listen()` to avoid disposal errors
6. **Premature Disposal** - Accessing `autoDispose` providers without listeners causes them to be disposed immediately. Always use `container.listen()` to keep them alive in tests.

## Organization

Test files should mirror source code (`lib`) structure.
All tests in `test/src/` with helpers in `test/helpers/`.

## Preventing Hangs and Leaks

- **ALWAYS use MockAppDatabase**:
  Never use `NativeDatabase.memory()` in widget tests or unit tests that don't explicitly need integration-level database behavior.
  Real database instances spawn background isolates and use timers that can cause tests to hang or fail with "Timer is still pending".
- **Override Controllers**:
  Background controllers (like `timelineCleanupController`) that use `Future.microtask` or listen to lifecycle events must be overridden with `(ref) {}` (no-op) in tests.
  This prevents them from firing async work that outlives the test widget tree.
- **Close Streams**:
  Ensure any streams created in `setUp` are properly closed or are mocked using `Stream.value([])` which completes immediately.
- **Dispose Containers**:
  If manually creating a `ProviderContainer`, always call `dispose()` in `tearDown`.

## Google Fonts in Tests

The app uses `google_fonts` for custom typography in `ThemeFactory`. Since
`flutter_test_config.dart` sets `GoogleFonts.config.allowRuntimeFetching = false`, tests
cannot fetch fonts over HTTP.

**Current state**: Fonts are NOT bundled as assets yet. Tests that call
`ThemeFactory.buildThemeData()` will fail.

**Workaround**: Test theming via `ColorScheme` roles directly without calling
`ThemeFactory.buildThemeData()`. The `theme_factory_test.dart` and
`component_theming_test.dart` use `oxocarbonDarkVariant.derivedScheme` to verify theme
roles without triggering font loading.

**Reference**: `test/src/app/theming/component_theming_test.dart`

```dart
// DO: Test ColorScheme roles directly
final darkCs = oxocarbonDarkVariant.derivedScheme;
expect(darkCs.secondaryContainer, const Color(0xFF0A4A79));

// DON'T: Call ThemeFactory.buildThemeData() - triggers font loading
final theme = ThemeFactory.buildThemeData(oxocarbonDarkVariant); // Fails!
```
