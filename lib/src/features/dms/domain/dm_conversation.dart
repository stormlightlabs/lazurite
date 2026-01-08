import '../../../infrastructure/db/app_database.dart';

/// Represents a direct message conversation.
///
/// Domain model combining data from the DmConvos table
/// with parsed member profiles for UI display.
class DmConversation {
  DmConversation({
    required this.convoId,
    required this.members,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastReadMessageId,
    required this.unreadCount,
    required this.isMuted,
    required this.isAccepted,
  });

  /// Conversation ID (unique identifier from API).
  final String convoId;

  /// Participant profiles in this conversation.
  final List<Profile> members;

  /// Preview text from the last message.
  final String? lastMessageText;

  /// Timestamp of the last message.
  final DateTime? lastMessageAt;

  /// ID of the last message the user has read.
  final String? lastReadMessageId;

  /// Number of unread messages.
  final int unreadCount;

  /// Whether the conversation is muted.
  final bool isMuted;

  /// Whether the conversation request has been accepted.
  final bool isAccepted;

  /// The other participant in a 1:1 conversation.
  ///
  /// For conversations with multiple members, returns the first member.
  Profile get otherParty => members.first;

  /// Whether there are unread messages.
  bool get hasUnread => unreadCount > 0;

  /// Returns a copy with updated fields.
  DmConversation copyWith({
    String? convoId,
    List<Profile>? members,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? lastReadMessageId,
    int? unreadCount,
    bool? isMuted,
    bool? isAccepted,
  }) {
    return DmConversation(
      convoId: convoId ?? this.convoId,
      members: members ?? this.members,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}
