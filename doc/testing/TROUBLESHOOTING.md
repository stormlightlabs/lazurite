# Troubleshooting & Pitfalls

Solutions for common testing issues and a list of anti-patterns to avoid.

## Common Pitfalls

1. **Forgetting to override providers:** Any screen with database streams or async providers needs mocked overrides in widget tests.
2. **Not closing databases:** Always close databases in `tearDown()` to prevent resource leaks and hanging processes.
3. **Using `Stream.empty()`:** Always use `Stream.value([])` for initial list values. `Stream.empty()` never emits, causing tests to hang.
4. **Missing navigation overrides:** Router tests must mock providers for all navigable screens.
5. **Testing stream providers with `.future`:** Use `container.listen()` to avoid errors where a provider is disposed before the future completes.
6. **Premature Disposal:** Accessing `autoDispose` providers without a listener causes immediate disposal.

## Preventing Hangs and Leaks

- **ALWAYS use MockAppDatabase:** Real database instances spawn background isolates and use timers that can cause tests to hang or fail with "Timer is still pending".
- **Override Controllers:** Background controllers (like `timelineCleanupController`) that use `Future.microtask` or listen to lifecycle events must be overridden with `(ref) {}` (no-op) in tests.
- **Close Streams:** Ensure any streams created in `setUp` are properly closed or mocked.
- **Dispose Containers:** If manually creating a `ProviderContainer`, always call `dispose()` in `tearDown`.

## "Timer is still pending" Errors

The most common widget test failure in Lazurite.

**Solutions:**

- Ensure all database-backed providers are mocked.
- Override background sync controllers with no-ops.
- If the test uses real timers/animations, use `tester.pumpAndSettle()`.
- Force a widget tree disposal at the end of the test: `await tester.pumpWidget(const Placeholder());`.

## Google Fonts in Tests

`GoogleFonts.config.allowRuntimeFetching` is set to `false` in `test_config.dart`. Since fonts aren't currently bundled as assets, calling `ThemeFactory.buildThemeData()` in tests will fail.

**Workaround:**
Test theming via `ColorScheme` roles directly without triggering font loading.

```dart
// DO: Test ColorScheme roles directly
final darkCs = oxocarbonDarkVariant.derivedScheme;
expect(darkCs.secondaryContainer, const Color(0xFF0A4A79));

// DON'T: Call ThemeFactory.buildThemeData()
final theme = ThemeFactory.buildThemeData(oxocarbonDarkVariant); // Fails!
```
