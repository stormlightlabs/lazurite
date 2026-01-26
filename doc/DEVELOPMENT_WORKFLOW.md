# Development Workflow

Guidelines for the daily development process in Lazurite.

## Code Generation

Lazurite relies heavily on code generation for Riverpod providers, Freezed models, and JSON serialization.

### Running Generation

Use the `justfile` recipe to run build_runner:

```sh
just gen
```

This is equivalent to: `dart run build_runner build --delete-conflicting-outputs`.

**Never edit generated files (`*.freezed.dart`, `*.g.dart`)**. If builds fail or become inconsistent, delete the `.dart_tool/build` directory and regenerate.

### Local Development Runs

For local smoke runs, use the following commands after fetching dependencies with `flutter pub get`:

- `flutter run -d android`
- `flutter run -d chrome`
- `flutter run -d ios`

## Style & Naming

### Dart Style

- **Indentation:** Use 2-space indentation.
- **Formatting:** All code must pass `dart format`. Run `just format` to format the entire project.
- **Linting:** Rules are defined in `analysis_options.yaml`. Address all `flutter analyze` diagnostics immediately. Run `just lint` to check.

### Naming Conventions

- **Widgets & Services:** Use `PascalCase` (e.g., `FeedService`, `PostCard`).
- **Members & Variables:** Use `lowerCamelCase`.
- **Files:** Use `snake_case` (e.g., `feature_feed_view.dart`).

### Dependency Injection

- DI wiring is centralized in `lib/src/core` to keep `main.dart` lean.

## Pre-Commit Checklist

Ensure your code meets quality standards before pushing:

1. `just format` - Standardize code formatting.
2. `just lint` - Run `flutter analyze` to catch potential issues.
3. `just gen` - Ensure all generated code is up to date.
4. `just test` - Run the full test suite (or `just test-quiet` to focus on failures).

Recommendation: Run `just check`, which performs all the above steps in sequence.

## Testing Standards

- **Location:** Place unit tests beside their feature mirror (e.g., `lib/src/features/feed` → `test/src/features/feed`).
- **Naming:** Test files must end with `_test.dart`.
- **Organization:** Group cases with `group()` labels describing behavior.
- **Coverage:** We aim for > 95% test coverage. Add `flutter test --coverage` when validating regressions.
- **Mocks:** Use fake data builders from `test/helpers` and avoid real network calls.

See the [Testing README](./testing/README.md) for detailed patterns.

## Commits

Commit history follows **Conventional Commits**:

- `feat:` for new features
- `fix:` for bug fixes
- `chore:` for maintenance
- `docs:` for documentation changes

## Common Pitfalls

1. **Loading Data in `build()`:** Avoid triggering expensive side effects directly in a Notifier's `build()` method. Initialize state to `loading` and use `Future.microtask()` or similar for side effects if needed.
2. **Repository Injection:** Don't store repository instances in notifier constructors. Use `ref.watch(provider)` or `ref.read(provider)` to access them.
3. **Hiding Errors:** Never swallow exceptions with an empty `catch` block. Always log the error and propagate a typed failure.
4. **Direct DAO Access:** UI and Application layers should never touch DAOs. Always go through a Repository.
5. **Circular Imports:** Follow the dependency direction strictly: `presentation -> application -> infrastructure -> domain`.
6. **Manual AsyncValue:** Let Riverpod handle `AsyncValue` automatically for `Future` and `Stream` providers.
