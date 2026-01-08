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
class OutboxItem {
  OutboxItem({
    required this.outboxId,
    required this.convoId,
    required this.messageText,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  /// Local UUID for this outbox item.
  final String outboxId;

  /// Conversation to send the message to.
  final String convoId;

  /// Message text content.
  final String messageText;

  /// Current status.
  final OutboxStatus status;

  /// Number of send attempts.
  final int retryCount;

  /// When the message was queued.
  final DateTime createdAt;

  /// When the last send attempt was made.
  final DateTime? lastAttemptAt;

  /// Error message from the last failed attempt.
  final String? errorMessage;

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

  /// Returns a copy with updated fields.
  OutboxItem copyWith({
    String? outboxId,
    String? convoId,
    String? messageText,
    OutboxStatus? status,
    int? retryCount,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return OutboxItem(
      outboxId: outboxId ?? this.outboxId,
      convoId: convoId ?? this.convoId,
      messageText: messageText ?? this.messageText,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
