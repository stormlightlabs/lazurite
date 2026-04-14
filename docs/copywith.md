# Nullable `copyWith` Rule

## Problem

A common state bug occurs when `copyWith` uses `field ?? this.field` for nullable fields.
That pattern cannot distinguish:

- "keep current value"
- "set this field to null"

This breaks flows where `null` is meaningful (for example clearing cursors, `likeUri`, `repostUri`, or `errorMessage`).

## Required Pattern

For nullable fields in immutable state objects, use a sentinel parameter default:

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

## Where Applied

- `SearchState.copyWith` (cursor and nullable metadata fields)
- `FeedState.copyWith` (cursor and error fields)
- `PostActionState.copyWith` (`likeUri`, `repostUri`, `error`)

## Review Checklist

- If a field is nullable and needs to be clearable, do not use `??` in `copyWith`.
- Add/keep tests that assert nullable fields can be explicitly cleared to `null`.
