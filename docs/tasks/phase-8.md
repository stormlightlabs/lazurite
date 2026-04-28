---
title: Phase 8 Task Breakdown
updated: 2026-04-27
---

## M27 - Follow Hygiene: Detect & Remove Inactive/Problematic Follows

Completed [2026-04-11](../../CHANGELOG.md#2026-04-11)

## M28 - Micro-Animations with flutter_animate

Spec: [animate.md](../specs/animate.md)

- [x] Add `flutter_animate` dependency
- [x] Create `lib/core/theme/animation_tokens.dart` with centralised durations, curves, stagger constants
- [x] Add reduced-motion utility (`animateIfAllowed` extension)
  - [x] Add setting for users to turn off animations
- [x] Feed & list items: staggered fade-in + slide-up on first appearance (track seen items to avoid re-animation)
- [x] Action feedback: scale-bounce on like / repost / bookmark tap
- [x] Screen transitions: fade-through `TransitionPage` wrapper for GoRouter
- [x] Shimmer loading: replace static skeleton placeholders with `.shimmer()` sweep
- [x] Bottom nav bar: scale + crossfade on active icon change
- [x] Snackbar / toast: slide-up entrance, fade-out dismiss
- [x] FAB / action buttons: scale-in on appear, scale-out on disappear
- [x] Pull-to-refresh: rotate + fade-out on completion
- [x] Profile header: parallax banner on scroll
- [x] Empty state: gentle fade + scale entrance
- [x] Widget tests for all animated widgets (pumpAndSettle, reduced-motion branch)
