# Testing Guide

Overview of the testing strategy, organization, and execution in Lazurite.

## Running Tests

Use the `just` recipes for a consistent testing experience:

- `just test`: Run tests with a 60s timeout and verbose output.
- `just test-quiet`: Run tests with a 30s timeout and quiet output (failures only). Useful for identifying hanging tests or pinpointing errors.
- `just check`: Run format, lint, and all tests. Recommended before any commit.

## Organization

Test files must mirror the `lib/src` directory structure.

- Source: `lib/src/features/feed/application/feed_notifier.dart`
- Test: `test/src/features/feed/application/feed_notifier_test.dart`

All shared test helpers and mocks are located in `test/helpers/`.

## Core Documentation

- [**Testing Patterns**](./PATTERNS.md): Guidance on Riverpod, Drift, and Async patterns.
- [**Tests By Type**](./BY_TYPE.md): Specific setup and examples for Widget, Repository, DAO, and Router tests.
- [**Troubleshooting & Pitfalls**](./TROUBLESHOOTING.md): Solutions for common issues like pending timers, memory leaks, and font loading.

## Reference Examples

- **Widget Tests:** `test/src/features/search/presentation/screens/search_screen_test.dart`
- **Repository Tests:** `test/src/features/feeds/infrastructure/feed_repository_test.dart`
- **DAO Tests:** `test/src/infrastructure/db/daos/saved_feeds_dao_test.dart`
- **Router Tests:** `test/src/app/router_test.dart`
