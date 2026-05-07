---
title: Code Patterns
updated: 2026-05-07
---

This document captures recurring architectural and implementation patterns in the Lazurite codebase.

## Code Organization

```sh
lib/
  ├── core/                       # cross-cutting app/platform concerns (router, theme, logging, network, database)
  ├── features/                   # feature-first modules
  │   └── {feature}               # one vertical slice per domain
  │       ├── data/               # repositories, DTO mapping, persistence/network access
  │       ├── bloc or cubit/      # state orchestration and business flow
  │       └── presentation/       # screens, widgets, and view-specific helpers
  └── shared/                     # reusable widgets/helpers/utils not tied to one feature
test/                             # mirrors production layout (core/features/shared) for unit/widget tests
docs/                             # specs, tasks, operational docs, and developer references
```

## State and UI Patterns

- Prefer immutable `Equatable` state with explicit `copyWith` semantics.
- Model state transitions in `Bloc`/`Cubit` layers; keep presentation widgets focused on rendering and user interactions.
- Use `sealed class` events and typed state classes to keep transitions explicit and testable.
- For repeated UI states, use shared widgets instead of ad-hoc `Center(...)` blocks:
  - `LoadingState`
  - `ErrorState`
  - `EmptyState`

## Extracted Reuse Patterns

### Utilities

`lib/shared/utils/format_utils.dart` is the canonical source for display primitives (initials, compact counts, relative time labels).
The extraction replaced repeated local formatters from feed/profile/search/notification surfaces with one tested implementation (`test/shared/utils/format_utils_test.dart`).

### Dialogs, Sheets, and Snackbars

Transient UI interaction patterns were consolidated into shared helpers and widgets:

- `showConfirmationDialog` for confirm/cancel flows
- `showOptionsSheet` for action menus
- `showAppSnackBar` for user feedback

This keeps behavior and semantics consistent across features and is covered with focused widget tests in `test/shared/presentation/...`.

### Theme Access and Tokens

Theme access should go through `lib/core/theme/theme_extensions.dart` (`context.theme`, `context.colorScheme`, `context.textTheme`) rather than repeated `Theme.of(...)` lookups.

For layout rhythm, reuse spacing tokens from `lib/core/theme/spacing.dart`.

For visual consistency in image treatment, use shared filters from `lib/core/theme/color_filters.dart`.

### Reusable Presentation Widgets

Repeated avatar/name/icon logic from the audit was extracted into shared primitives. Prefer:

- `ProfileAvatar` (`lib/shared/presentation/widgets/profile_avatar.dart`) for all profile/list/feed avatar rendering, including fallback and moderation-aware masking behavior.
- `ActorNameWidget` (`lib/shared/presentation/widgets/actor_name_widget.dart`) for standardized display-name + handle rows (used in feed cards, embedded records, and conversation items).
- `NotificationIconMapper` (`lib/shared/presentation/helpers/notification_icon_mapper.dart`) for mapping notification reason to icon + color style, instead of local switch blocks.

### Navigation and Haptics

Navigation/haptic side effects also follow shared helper entry points.
Use `navigateToProfile` and `navigateToPost` for common entity navigation, and route tactile feedback through `HapticHelper` instead of direct `HapticFeedback` calls in feature widgets.

## Other Recurring Codebase Patterns

- Feature-first vertical slices under `lib/features/{feature}/{data,bloc|cubit,presentation}` keep business logic close to owning UI while preserving cross-feature boundaries.
- Dependency injection is explicit at composition boundaries (`RepositoryProvider`/`BlocProvider` in app and screen roots), which makes screens and blocs easy to test in isolation.
- Repository interfaces return typed results (often with cursor pagination) instead of raw maps, keeping API edges explicit and testable.
- Defensive fallback behavior is preferred for unstable integrations; for example, repository logic that falls back on alternative endpoints when one API path fails is covered by contract tests.
- Shared moderation-aware rendering is treated as a first-class cross-feature concern (`ModerationUI`, `ModerationBadgeRow`, `ModeratedBlurOverlay`, `ProfileAvatar` moderation hooks).
- Use fully-qualified package imports (`package:lazurite/...`) for internal modules.

## Moderation-Aware Rendering Pattern

- For actor/content media that can be moderated, request moderation UI state via moderation service helpers and pass it into rendering widgets.
- `ProfileAvatar` supports moderated fallback/masking through `ModerationUI`.
- Compose moderation badges/overlays (`ModerationBadgeRow`, `ModeratedBlurOverlay`) at feature widget boundaries.

## Nullable `copyWith` Pattern (Required)

For nullable fields in immutable state, **do not** use `field ?? this.field` when `null` is a meaningful explicit update.

Use a sentinel default to distinguish:

- keep current value
- set value to `null`

```dart
static const Object _unset = Object();

State copyWith({
  Object? nullableField = _unset,
}) {
  return State(
    nullableField: identical(nullableField, _unset)
        ? this.nullableField
        : nullableField as String?,
  );
}
```

### Review Checklist

- For clearable nullable fields, avoid `??` fallback in `copyWith`.
- Add tests proving nullable fields can be explicitly cleared.

## Testing Patterns

- Per-file setup builders are standard (`buildSubject(...)`, plus helpers like `openSheet(...)`) so test bodies focus on behavior, not setup.
- Widget tests usually mount through `MaterialApp`/`Scaffold` for component tests, and `MaterialApp.router` + `GoRouter` for navigation tests.
- Interaction flow follows a consistent shape:
  `pumpWidget` -> input (`tap`, `enterText`) -> `pump`/`pumpAndSettle` -> assertions on visible UI and side effects.
- BLoC/Cubit widget tests rely on `mocktail` + `bloc_test` (`MockBloc`, `MockCubit`, `when`, `whenListen`, `verify`, `verifyNever`), with `registerFallbackValue` in `setUpAll` when needed.
- Router behavior is verified by capturing the pushed route URI and asserting path/query params
- Complex service/repository tests use fit-for-purpose doubles:
  - `MockClient` from `http/testing.dart` for HTTP-level contracts
  - Small local fake implementations when protocol surfaces are complex
- Async UI timing is made explicit where animations/debounce are relevant (`pump(const Duration(...))` in sheet/search tests), and responsive behavior is exercised with `setSurfaceSize` in router/shell tests.
- Defensive assertions are common: boundary-value checks in utility tests, null/empty/error-path repository tests, and `expect(tester.takeException(), isNull)` guards in navigation/router tests.
