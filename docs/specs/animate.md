---
title: Micro-Animations Spec
updated: 2026-04-27
---

## Summary

Add polished micro-animations across the app using `flutter_animate` to bring
life to transitions, state changes, and user interactions. The goal is subtle,
fast, purposeful motion — not decorative. Every animation must serve
orientation ("where am I?"), feedback ("did that work?"), or continuity
("what just changed?").

## Package

**`flutter_animate`** (pub.dev) — declarative, composable animation chains
via extension methods on `Widget`. Chosen over raw `AnimationController` /
`ImplicitlyAnimatedWidget` for consistency and velocity: a single API for
fade, slide, scale, blur, shimmer, and custom effects, with built-in
stagger support.

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_animate: ^4.5.2
```

## Animation Inventory

### 1. Feed & List Items — Staggered Entrance

**Where:** Post cards in feed, notification rows, search results, follow
audit results, list members, saved posts.

**Effect:** Each item fades in + slides up as it enters the viewport for the
first time (initial load or pagination append).

```dart
child
  .animate()
  .fadeIn(duration: 200.ms, curve: Curves.easeOut)
  .slideY(begin: 0.05, end: 0, duration: 200.ms, curve: Curves.easeOut)
```

Stagger: 50ms offset per item (capped at 10 items per batch to avoid long
entrance sequences on large pages).

**Constraint:** Only on first appearance. Scrolling back to an already-seen
item must not re-animate. Track via a `Set<String>` of post URIs (or item
keys) in the feed cubit/bloc.

### 2. Action Feedback — Like, Repost, Bookmark

**Where:** Post action bar icons.

**Effect:** On tap, the icon scales up briefly then settles back, with a
color crossfade to the active tint.

```dart
icon
  .animate(onPlay: (c) => c.forward())
  .scale(begin: 1.0, end: 1.3, duration: 120.ms, curve: Curves.easeOut)
  .then()
  .scale(begin: 1.3, end: 1.0, duration: 100.ms, curve: Curves.easeOutBack)
```

The color change uses `AnimatedSwitcher` or `ColorTween` on the existing
icon — `flutter_animate`'s `.tint()` effect is an alternative.

### 3. Screen Transitions — Fade-Through

**Where:** All `GoRouter` page transitions (currently using default Material
platform transitions).

**Effect:** Material fade-through (outgoing screen fades out + scales down
slightly, incoming screen fades in + scales up slightly). Duration 300ms.

Implement via a custom `TransitionPage` wrapper:

```dart
class FadeThroughPage<T> extends CustomTransitionPage<T> {
  FadeThroughPage({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
```

Use `animations` package's `FadeThroughTransition` or implement manually
with `flutter_animate` chained fade + scale.

### 4. Skeleton / Shimmer Loading

**Where:** Feed loading placeholders, profile header loading, notification
list loading — anywhere a shimmer placeholder is shown.

**Effect:** Replace static grey boxes with a shimmer sweep using
`.shimmer(duration: 1200.ms, color: theme.colorScheme.surfaceContainerHigh)`.

```dart
Container(
  height: 16, width: 120,
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.zero, // square geometry per UI refactor
  ),
)
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1200.ms, color: theme.colorScheme.surfaceContainerHigh)
```

### 5. Bottom Navigation Bar — Icon Transition

**Where:** Bottom nav bar active/inactive icon swap.

**Effect:** Active icon scales up from 1.0 to 1.15 with a fade crossfade
between outlined → filled icon variants. Duration 150ms.

### 6. Snackbar / Toast Entrance

**Where:** All snackbar and toast messages.

**Effect:** Slide up from bottom + fade in (200ms). On dismiss, fade out +
slide down (150ms).

### 7. FAB / Action Button

**Where:** Compose FAB, gallery FAB, scroll-to-top button.

**Effect:** Scale-in on appear (`scaleXY` 0 → 1, 200ms, `Curves.easeOutBack`).
Scale-out on disappear (reverse).

### 8. Pull-to-Refresh Indicator

**Where:** Feed and list pull-to-refresh.

**Effect:** The refresh indicator rotates continuously during refresh, then
scales down + fades out on completion (200ms).

### 9. Profile Header — Parallax

**Where:** Profile screen banner image.

**Effect:** Subtle parallax on scroll — banner moves at 0.5x scroll speed.
Implemented via `SliverAppBar`'s existing `flexibleSpace` with a
`Transform.translate` driven by scroll offset, not `flutter_animate`.

### 10. Empty State Illustrations

**Where:** Empty feeds, no search results, no notifications.

**Effect:** Fade in + gentle scale from 0.95 to 1.0 (300ms, ease-out).
Prevents the "flash" of empty state content.

## Animation Tokens

Centralise timing and curves in a single file to keep motion consistent:

**`lib/core/theme/animation_tokens.dart`**

```dart
abstract final class Anim {
  // Durations
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  // Curves
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
  static const emphasis = Curves.easeOutBack;

  // Stagger
  static const staggerOffset = Duration(milliseconds: 50);
  static const maxStaggerItems = 10;
}
```

All animations in the codebase reference these tokens — no magic numbers
in widget files.

## Reduced Motion

Respect the platform's "reduce motion" accessibility setting:

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
```

When `reduceMotion` is true, skip all non-essential animations. Essential
transitions (screen changes) use a simple crossfade at 150ms. Loading
shimmers continue (they convey information, not decoration).

Wrap in a utility:

```dart
extension AnimateAccessibility on Widget {
  Widget animateIfAllowed(BuildContext context, List<Effect> effects) {
    if (MediaQuery.of(context).disableAnimations) return this;
    return animate(effects: effects);
  }
}
```

## Performance

- All animations use `flutter_animate`'s transform-based effects (GPU
  composited) — avoid layout-triggering properties like width/height
  animation on list items.
- Stagger caps at 10 items to avoid jank on low-end devices.
- Profile the animation layer with Flutter DevTools' performance overlay
  before merge — target 0 skipped frames on a mid-range Android device
  (Pixel 6a equivalent).
- Feed item animations are fire-once; re-scrolling does not re-trigger.

## Testing

- Unit test `Anim` token values (sanity check, constants don't drift).
- Widget tests for animated widgets use `tester.pumpAndSettle()` to
  complete animations, then assert final visual state.
- Widget tests for reduced-motion: set `MediaQuery.disableAnimations`
  to `true`, verify no `Animate` widget in the tree.
- Golden tests for shimmer placeholders (capture mid-animation frame).

## Scope & Constraints

- **No animated illustrations or Lottie.** All motion is CSS-style
  property animation — no custom vector art or frame-based animation.
- **No animation preferences screen.** We respect the OS-level reduced
  motion toggle only. A per-app toggle is out of scope.
- **No physics-based animations** (springs, flings) in this pass.
  `flutter_animate` supports them but they're harder to keep consistent.
  Evaluate in a future milestone.
