# Repository Guidelines

## Project Structure & Module Organization

```sh
.
├── lib/
│   └── src/
│       ├── app/                # Bootstrap widgets
│       ├── core/               # Shared utilities
│       ├── features/           # User-facing flows
│       └── infrastructure/     # Network + persistence
├── test/
│   └── src/
├── android/                    # Android app
├── ios/                        # iOS app
├── doc/                        # Documentation
├── build/                      # Build artifacts
└── coverage/                   # Test coverage
```

## Development Commands

Use `just` targets:

- `just format` runs `dart format lib test`.
- `just lint` proxies `flutter analyze`.
- `just test` executes the full `flutter test` suite.
    - To pinpoint errors, use `just test-quiet` for cleaner output.
- `just gen` invokes `dart run build_runner build --delete-conflicting-outputs`.
- `just check` performs format + lint + test before commits.

For local smoke runs, use `flutter run -d android`, `flutter run -d chrome`, or `flutter run -d ios`
(once dependencies are fetched with `flutter pub get`).

## Style & Naming

Dart files use 2-space indentation and must pass `dart format`.

Follow Flutter’s preferred naming: PascalCase for widgets/services, lowerCamelCase for
members, and snake_case for files like `feature_feed_view.dart`.

Linting rules are in `analysis_options.yaml`.  Address `flutter analyze` diagnostics as
quickly as possible.

DI wiring is centralized in `lib/src/core` to keep `main.dart` lean.

## Testing

Place unit tests beside their feature mirror (e.g., `lib/src/features/feed` → `test/src/features/feed`). Test files end with `_test.dart` and group cases with `group()` labels describing behavior.

Run `just test` before pushing; add `flutter test --coverage` when validating regressions that touch networking or auth. As stated above, use `test-quiet` for quieter output (this is
equivalent to running `flutter test --reporter=failures-only`)

We prefer fake data builders from `test/helpers` and avoid real network calls.
The infrastructure layer already exposes abstraction seams for mocking.

We aim for > 95% coverage targets.

Common pitfalls are documented in a dedicated [testing](./doc/testing.md) document.

## Commits

Commit history follows Conventional Commits (`feat:`, `fix:`, `chore:`).
