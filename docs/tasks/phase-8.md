---
title: Phase 8 Task Breakdown
updated: 2026-04-27
---

## M27 - Follow Hygiene: Detect & Remove Inactive/Problematic Follows

Completed [2026-04-11](../../CHANGELOG.md#2026-04-11)

## M28 - Micro-Animations with flutter_animate

Spec: [animate.md](../specs/animate.md)

- [x] Add `flutter_animate` dependency
- [ ] Create `lib/core/theme/animation_tokens.dart` with centralised durations, curves, stagger constants
- [ ] Add reduced-motion utility (`animateIfAllowed` extension)
  - [ ] Add setting for users to turn off animations
- [ ] Feed & list items: staggered fade-in + slide-up on first appearance (track seen items to avoid re-animation)
- [ ] Action feedback: scale-bounce on like / repost / bookmark tap
- [ ] Screen transitions: fade-through `TransitionPage` wrapper for GoRouter
- [ ] Shimmer loading: replace static skeleton placeholders with `.shimmer()` sweep
- [ ] Bottom nav bar: scale + crossfade on active icon change
- [ ] Snackbar / toast: slide-up entrance, fade-out dismiss
- [ ] FAB / action buttons: scale-in on appear, scale-out on disappear
- [ ] Pull-to-refresh: rotate + fade-out on completion
- [ ] Profile header: parallax banner on scroll
- [ ] Empty state: gentle fade + scale entrance
- [ ] Widget tests for all animated widgets (pumpAndSettle, reduced-motion branch)
