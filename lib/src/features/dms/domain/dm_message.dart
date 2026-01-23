import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';

part 'dm_message.freezed.dart';
part 'dm_message.g.dart';

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
@freezed
abstract class AppDmMessage with _$AppDmMessage {
  const factory AppDmMessage({
    /// Message ID (unique identifier from API or local UUID for pending).
    required String messageId,

    /// Conversation this message belongs to.
    required String convoId,

    /// The message sender's profile.
    required Author sender,

    /// Message text content.
    required String content,

    /// When the message was sent.
    required DateTime sentAt,

    /// Current delivery status.
    required MessageStatus status,
  }) = _AppDmMessage;

  const AppDmMessage._();

  factory AppDmMessage.fromJson(Map<String, dynamic> json) => _$AppDmMessageFromJson(json);

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
}
