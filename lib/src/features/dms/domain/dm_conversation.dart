import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';

part 'dm_conversation.freezed.dart';
part 'dm_conversation.g.dart';

/// Represents a direct message conversation.
///
/// Domain model combining data from the DmConvos table
/// with parsed member profiles for UI display.
@freezed
abstract class DmConversation with _$DmConversation {
  const factory DmConversation({
    /// Conversation ID (unique identifier from API).
    required String convoId,

    /// Participant profiles in this conversation.
    required List<Author> members,

    /// Preview text from the last message.
    String? lastMessageText,

    /// Timestamp of the last message.
    DateTime? lastMessageAt,

    /// ID of the last message the user has read.
    String? lastReadMessageId,

    /// Number of unread messages.
    required int unreadCount,

    /// Whether the conversation is muted.
    required bool isMuted,

    /// Whether the conversation request has been accepted.
    required bool isAccepted,
  }) = _DmConversation;

  const DmConversation._();

  factory DmConversation.fromJson(Map<String, dynamic> json) => _$DmConversationFromJson(json);

  /// The other participant in a 1:1 conversation.
  ///
  /// For conversations with multiple members, returns the first member.
  Author get otherParty => members.first;

  /// Whether there are unread messages.
  bool get hasUnread => unreadCount > 0;
}
