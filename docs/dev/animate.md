---
title: Motion Developer Notes
updated: 2026-05-07
---

Lazurite uses small motion cues to show navigation, feedback, and loading
state. Motion should help the user understand what changed. It should not draw
attention to itself.

`flutter_animate` is the shared animation package for widget-level effects such
as fades, slides, scales, shimmer, and staggered entrances. Use raw controllers
only when the interaction needs custom timing or scroll-driven behavior that
the shared package does not fit.

## Shared Tokens

Animation durations, curves, and stagger offsets belong in
`lib/core/theme/animation_tokens.dart`. Widget files should use those tokens
instead of local magic numbers. This keeps feed cards, snackbars, buttons, and
empty states moving at the same pace.

Common timing buckets are fast feedback, normal entrance or exit, and slower
state transitions. Staggered lists cap the number of offset items so pagination
does not create long delayed sequences.

## Where Motion Is Used

Feed cards, notification rows, search results, follow-audit rows, list members,
and saved posts use a one-time entrance as new items appear. Track seen item
keys so scrolling back does not replay the animation.

Like, repost, and bookmark controls use short scale feedback when toggled.
Bottom navigation uses a small active-icon transition. Floating action buttons
scale in when they appear and scale out when removed. Snackbars enter from the
bottom and dismiss quickly.

Loading placeholders use shimmer where it communicates waiting for content with
known shape. Empty states fade and scale in once, avoiding abrupt swaps between
loading and empty UI.

Profile banner parallax is scroll-driven and should stay separate from
`flutter_animate`. It is implemented with scroll offset and transforms so it
does not trigger layout work.

## Reduced Motion

Respect `MediaQuery.disableAnimations`. When the platform asks for reduced
motion, skip nonessential transitions. Route changes can use a short crossfade,
and loading indicators may continue when they communicate progress rather than
decoration.

Reduced-motion behavior needs widget coverage. Tests should mount the widget
with disabled animations and verify that optional animation wrappers are not in
the tree or that the final state is reached without waiting for motion.

## Performance And Tests

Prefer transform and opacity effects because they stay on the compositor path.
Avoid animating dimensions in scrolling lists. Check feed and profile surfaces
with Flutter performance tools when adding broad motion.

Tests should settle animations before checking final state. Token tests guard
against accidental timing drift, while focused widget tests cover action
feedback, reduced motion, shimmer placeholders, and one-time list entrances.
