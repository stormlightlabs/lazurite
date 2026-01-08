import '../../../infrastructure/db/app_database.dart';

/// Message delivery status enum.
enum MessageStatus {
  /// Message is in outbox, not yet sent.
  pending,

  /// Message is currently being uploaded.
  sending,

  /// Message was successfully delivered to server.
  sent,

  /// Message has been read by recipient.
  read,

  /// Message send failed (user can retry).
  failed,

  /// Message was deleted.
  deleted;

  /// Parses a status string from the database.
  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => MessageStatus.sent,
    );
  }
}

/// Represents a direct message in a conversation.
///
/// Domain model combining data from the DmMessages table
/// with the sender profile for UI display.
class AppDmMessage {
  AppDmMessage({
    required this.messageId,
    required this.convoId,
    required this.sender,
    required this.content,
    required this.sentAt,
    required this.status,
  });

  /// Message ID (unique identifier from API or local UUID for pending).
  final String messageId;

  /// Conversation this message belongs to.
  final String convoId;

  /// The message sender's profile.
  final Profile sender;

  /// Message text content.
  final String content;

  /// When the message was sent.
  final DateTime sentAt;

  /// Current delivery status.
  final MessageStatus status;

  /// Whether this message is still pending send.
  bool get isPending => status == MessageStatus.pending;

  /// Whether this message is currently being sent.
  bool get isSending => status == MessageStatus.sending;

  /// Whether this message was successfully sent.
  bool get isSent => status == MessageStatus.sent;

  /// Whether this message has been read by the recipient.
  bool get isRead => status == MessageStatus.read;

  /// Whether this message failed to send.
  bool get isFailed => status == MessageStatus.failed;

  /// Whether this message was deleted.
  bool get isDeleted => status == MessageStatus.deleted;

  /// Returns a copy with updated fields.
  AppDmMessage copyWith({
    String? messageId,
    String? convoId,
    Profile? sender,
    String? content,
    DateTime? sentAt,
    MessageStatus? status,
  }) {
    return AppDmMessage(
      messageId: messageId ?? this.messageId,
      convoId: convoId ?? this.convoId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
    );
  }
}
