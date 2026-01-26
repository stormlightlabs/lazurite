# Tests By Type

Specific setup patterns and implementation details for different types of tests in Lazurite.

## Widget Tests

**Reference:** `test/src/features/search/presentation/screens/search_screen_test.dart`

Widget tests verify UI components and their interaction with application state.

### Key Rules

- **Mock Repositories:** Return `Stream.value([])` for immediate completion to avoid hanging tests.
- **ProviderScope:** Use `ProviderScope` in your test setup to override providers that Fetch data or interact with databases.
- **Use `MockAppDatabase`:** **CRITICAL**. Never use a real `AppDatabase` or `NativeDatabase.memory()` in widget tests. This prevents timer leaks and background isolate issues.
- **Pump and Settle:** Use `tester.pumpWidget()` followed by `tester.pump()` or `tester.pumpAndSettle()` to process initial builds and async operations.

## App & Router Tests

**Reference:** `test/src/app/router_test.dart`

These tests verify navigation and cross-feature integration.

### Setup Pattern

- **Override ALL providers:** Ensure every screen navigable during the test has its dependencies mocked.
- **Mock Repositories in `setUp()`:** Reset state between navigation steps.
- **Close Databases:** Always close any database infrastructure in `tearDown()`.
- **Navigation Verification:** Verify that the expected widget is rendered after a navigation trigger.

## Repository Tests

**Reference:** `test/src/features/feeds/infrastructure/feed_repository_test.dart`

These tests verify business logic and data transformation in the infrastructure layer.

### Pattern

- **Mock DAOs and Clients:** Isolate the repository from real network/database calls.
- **Verify Transformations:** Ensure the repository correctly maps API JSON or Database Rows to Domain Models.
- **Check Verifications:** Use `verify(() => ...)`.

## DAO Tests

**Reference:** `test/src/infrastructure/db/daos/saved_feeds_dao_test.dart`

These tests verify actual SQL operations using in-memory databases.

### Pattern

- **Use `NativeDatabase.memory()`:** Test actual CRUD logic against a real (but transient) SQLite instance.
- **Watch Streams:** Use `.first` on `watch` methods to verify results.
- **Cleanup:** Always call `db.close()` in `tearDown()`.

## Stream Provider Tests

**Reference:** `test/src/features/settings/application/settings_providers_test.dart`

### Pattern

- **Avoid `.future`:** Don't use `await container.read(provider.future)` if the container is disposed in `tearDown()`, as it may cause disposal errors.
- **Use `container.listen()`:** Monitor state changes without holding a reference that prevents disposal.
