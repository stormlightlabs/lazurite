# Theming System

## Overview

- Many Material 3 components rely on the broader set of tone-based
  surfaces/containers and "onSurfaceVariant/outlineVariant" emphasis roles.
- Material 3 is explicitly designed around *color roles* applied consistently
  across UI.
- Flutter has been expanding Material 3 ColorScheme roles (tone surfaces +
  containers, and more accent roles), and some older roles are deprecated (e.g.,
  background/onBackground, surfaceVariant).

## Architecture

### Core Types

**ThemePack** (`lib/src/app/theming/theme_pack.dart`)

- Collection of theme variants (e.g., "Oxocarbon" pack with light/dark variants)
- Contains metadata: id, name, author
- Provides accessors: `lightVariant`, `darkVariant`, `getVariant(id)`

**ThemeVariant** (`lib/src/app/theming/theme_variant.dart`)

- Single brightness variant with a Material 3 ColorScheme
- Built from ThemeSpec palette definitions
- Contains: id, brightness, derivedScheme

**ThemeSpec** (`lib/src/app/theming/theme_spec.dart`)

- Palette definition for a theme variant
- Maps raw colors to M3 ColorScheme roles
- Defines: surfaces, containers, outlines, accents, typography, shapes

**ThemeFactory** (`lib/src/app/theming/theme_factory.dart`)

- Builds complete ThemeData from ThemeVariant
- Centralizes component themes (NavBar, Chips, Cards, ListTiles, Dividers, Inputs)
- Ensures consistent M3 role usage across all components

### Principles (Material 3)

- Use semantic color roles (surface containers, outlineVariant,
  onSurfaceVariant) rather than raw hex values sprinkled through widgets.
- Create hierarchy with tone-based surfaces/containers rather than heavy
  dividers.
- Navigation components must have a clear active indicator (selected state).
- Chips have specific color roles in spec (filter chip uses onSurfaceVariant +
  outline and optionally surfaceContainerLow).

## Material 3 Role Usage

### Surface Containers (Hierarchy)

Tone-based surfaces create visual hierarchy without heavy elevation:

```text
surfaceContainerLowest  ← dialogs, sheets (highest elevation)
surfaceContainerHigh    ← embeds, elevated cards
surfaceContainer        ← default containers
surfaceContainerLow     ← posts, cards (slightly elevated)
surface                 ← base background
surfaceDim/surfaceBright ← adaptive surface tones
```

### Component Patterns

#### NavigationBar

- Active indicator: uses container role (NOT primary tint overlay)
- Selected icons/labels: onSurface
- Unselected icons/labels: onSurfaceVariant

#### FilterChips (Feed selector)

- Unselected: outline + onSurfaceVariant
- Selected: secondaryContainer + onSecondaryContainer

#### Cards (Posts)

- Use surfaceContainerLow for slight elevation from background
- Embeds use surfaceContainerHigh (higher than parent post)

#### Dividers

- Default: outlineVariant (subtle)
- Emphasized boundaries: outline

#### Text Emphasis

- Body text: onSurface (highest legibility)
- Metadata (handle, timestamp): onSurfaceVariant

## Creating Theme Packs

### 1. Define Palette

Map your palette to M3 surface/container/outline/accent roles:

```dart
final mySpec = ThemeSpec(
  // Base surfaces
  surface: Color(0xFF1A1A1A),
  surfaceDim: Color(0xFF121212),
  surfaceBright: Color(0xFF242424),

  // Container ladder (dark theme: lowest is darkest)
  surfaceContainerLowest: Color(0xFF0F0F0F),
  surfaceContainerLow: Color(0xFF1E1E1E),
  surfaceContainer: Color(0xFF242424),
  surfaceContainerHigh: Color(0xFF2E2E2E),
  surfaceContainerHighest: Color(0xFF393939),

  // Outlines
  outline: Color(0xFF525252),
  outlineVariant: Color(0xFF393939),

  // Text
  onSurface: Color(0xFFF2F4F8),
  onSurfaceVariant: Color(0xFFB0B0B0),

  // Accents
  primary: Color(0xFF0085FF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF78A9FF),
  onSecondary: Color(0xFF000000),
  // ... other accent roles
);
```

### 2. Create Variants

```dart
final darkVariant = ThemeVariant(
  id: 'mypack-dark',
  brightness: Brightness.dark,
  spec: myDarkSpec,
);

final lightVariant = ThemeVariant(
  id: 'mypack-light',
  brightness: Brightness.light,
  spec: myLightSpec,
);
```

### 3. Build ThemePack

```dart
final myPack = ThemePack(
  id: 'mypack',
  name: 'My Pack',
  author: 'Me',
  variants: [darkVariant, lightVariant],
);
```

### 4. Validate with Role Lint Tests

Role lint checks ensure:

- All required M3 roles are defined
- Hierarchy integrity (surface != surfaceContainerLow, etc.)
- Container ladder ordering matches brightness (dark: lowest is darkest, light: lowest is lightest)
- Emphasis differentiation (onSurface != onSurfaceVariant)

## Accent Strategy by Theme Type

### High-contrast themes (Oxocarbon, One Dark)

- Use vivid primary colors
- Strong secondary/tertiary for highlights

### Pastel themes (Catppuccin, Rosé Pine, Nord)

- Keep accents restrained
- Use secondary for chips, tertiary for highlights
- Avoid overwhelming soft palettes with saturated accents
