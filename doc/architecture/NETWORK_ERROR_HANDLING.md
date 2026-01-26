# Network & Error Handling

Patterns for managing API requests and propagating failures correctly.

## Error Handling

### Typed Failure Hierarchies

Create specific failure subtypes for each error scenario using Freezed sealed classes. Never use generic exceptions for expected error conditions.

**Reference:** `NetworkFailure` in `lib/src/infrastructure/network/network_failure.dart`

Include both a user-friendly `message` and the root `cause` (exception). Add context-specific fields like `statusCode` or `retryAfter`.

### Error Conversion Boundaries

Convert raw exceptions (like `DioException`) into typed failures at the infrastructure boundary (e.g., in the `XrpcClient` or specific Repositories).

```dart
// In XrpcClient or similar
try {
  final response = await dio.post(...);
  return response.data;
} on DioException catch (e) {
  throw _convertDioError(e); // Returns a NetworkFailure
}
```

Repositories should propagate these typed failures upwards. Avoid redundant wrapping if the failure is already typed.

## Network Layer

### Centralized Client Routing

The `XrpcClient` serves as the single entry point for AT Protocol requests, handling host routing, authentication, and error conversion.

**Reference:** `XrpcClient` in `lib/src/infrastructure/network/xrpc_client.dart`

Key Responsibilities:

- **Host Selection:** Choosing between public AppView and user PDS based on the request.
- **Service Proxying:** Adding the `atproto-proxy` header for services like DMs.
- **Auth Interception:** Automatically adding tokens and handling 401 retries.
- **Error Normalization:** Converting diverse API error formats into a consistent `NetworkFailure`.

### Multi-Account Isolation

All user-scoped operations must respect multi-account isolation by filtering by `ownerDid`.

**Reference:** `Multi-Account Data Isolation` in `doc/ARCHITECTURE.md`.
