import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_item.freezed.dart';
part 'outbox_item.g.dart';

/// Outbox item status enum.
@JsonEnum()
enum OutboxStatus {
  /// Message is ready to send.
  pending,

  /// Message is currently being processed.
  sending,

  /// Message send failed (will retry or user can retry).
  failed;

  /// Parses a status string from the database (for backwards compatibility).
  static OutboxStatus fromString(String value) {
    return OutboxStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OutboxStatus.pending,
    );
  }
}

/// Represents a pending message in the outbox queue.
@freezed
abstract class OutboxItem with _$OutboxItem {
  factory OutboxItem.fromJson(Map<String, dynamic> json) => _$OutboxItemFromJson(json);
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

  @override
  Map<String, dynamic> toJson() => _$OutboxItemToJson(this as _OutboxItem);

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
  Duration get nextRetryDelay => Duration(seconds: 1 << (retryCount + 1));
}
