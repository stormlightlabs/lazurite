# Error Handling Patterns

This project standardizes error handling so UI messages stay user-friendly and
network failures are predictable.

## Standard Error Types

- `NetworkFailure` (in `lib/src/infrastructure/network/network_failure.dart`)
    - `ConnectionFailure`, `AuthFailure`, `RateLimitFailure`, `ClientFailure`,
    `ServerFailure`, `DecodeFailure`
- `OAuthException` (in `lib/src/infrastructure/auth/oauth_exceptions.dart`)
- `ValidationError` (in `lib/src/features/dms/domain/outbox_error.dart`)

## UI Messaging

Use `errorMessage(error)` from `lib/src/core/utils/error_message.dart` instead of
`error.toString()` to avoid leaking raw exception text into the UI.

Example:

```dart
ErrorView(
  title: 'Failed to load feed',
  message: errorMessage(error),
  onRetry: () => ref.read(feedContentProvider(uri).notifier).refresh(),
);
```

## Logging vs Display

- Log raw errors and stacks for debugging (`logger.error(...)`).
- Display standardized UI messages via `errorMessage(...)`.
- Prefer typed errors (e.g., `NetworkFailure`) at repository boundaries.

## Tests

Add or update tests whenever new error types are introduced or UI messaging
changes, especially for networking/auth flows.
