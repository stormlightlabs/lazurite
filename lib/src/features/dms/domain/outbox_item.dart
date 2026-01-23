import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_item.freezed.dart';

/// Outbox item status enum.
enum OutboxStatus {
  /// Message is ready to send.
  pending,

  /// Message is currently being processed.
  sending,

  /// Message send failed (will retry or user can retry).
  failed;

  /// Parses a status string from the database.
  static OutboxStatus fromString(String value) {
    return OutboxStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OutboxStatus.pending,
    );
  }
}

/// Represents a pending message in the outbox queue.
///
/// Domain model for DmOutbox table with retry logic methods.
@freezed
abstract class OutboxItem with _$OutboxItem {
  const factory OutboxItem({
    /// Local UUID for this outbox item.
    required String outboxId,

    /// Conversation to send the message to.
    required String convoId,

    /// Message text content.
    required String messageText,

    /// Current status.
    required OutboxStatus status,

    /// Number of send attempts.
    required int retryCount,

    /// When the message was queued.
    required DateTime createdAt,

    /// When the last send attempt was made.
    DateTime? lastAttemptAt,

    /// Error message from the last failed attempt.
    String? errorMessage,
  }) = _OutboxItem;

  const OutboxItem._();

  /// Maximum number of retry attempts before permanent failure.
  static const int maxRetries = 5;

  /// Whether this item can be retried.
  bool get canRetry => retryCount < maxRetries;

  /// Whether this item has permanently failed.
  bool get isPermanentlyFailed => retryCount >= maxRetries;

  /// Whether this item is ready to send.
  bool get isPending => status == OutboxStatus.pending;

  /// Whether this item is currently sending.
  bool get isSending => status == OutboxStatus.sending;

  /// Whether this item has failed.
  bool get isFailed => status == OutboxStatus.failed;

  /// Calculates the delay before next retry using exponential backoff.
  ///
  /// Delay = 2^retryCount seconds (2s, 4s, 8s, 16s, 32s).
  Duration get nextRetryDelay => Duration(seconds: 1 << (retryCount + 1));
}
