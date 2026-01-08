import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dm_messages_dao.g.dart';

/// DAO for managing cached DM messages.
///
/// Handles storage and retrieval of messages from
/// chat.bsky.convo.getMessages API.
@DriftAccessor(tables: [DmMessages, Profiles])
class DmMessagesDao extends DatabaseAccessor<AppDatabase> with _$DmMessagesDaoMixin {
  DmMessagesDao(super.db);

  /// Inserts or updates a batch of messages.
  Future<void> insertMessagesBatch({
    required List<DmMessagesCompanion> newMessages,
    required List<ProfilesCompanion> newProfiles,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(dmMessages, newMessages, mode: InsertMode.insertOrReplace);
      });
    });
  }

  /// Gets a stream of messages for a conversation sorted by sentAt ascending for a specific user.
  Stream<List<DmMessageWithSender>> watchMessagesByConvo(String convoId, String ownerDid) {
    final query = select(
      dmMessages,
    ).join([innerJoin(profiles, profiles.did.equalsExp(dmMessages.senderDid))]);
    query.where(dmMessages.convoId.equals(convoId) & dmMessages.ownerDid.equals(ownerDid));
    query.orderBy([OrderingTerm.asc(dmMessages.sentAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DmMessageWithSender(
          message: row.readTable(dmMessages),
          sender: row.readTable(profiles),
        );
      }).toList();
    });
  }

  /// Gets messages for a conversation (non-streaming).
  Future<List<DmMessageWithSender>> getMessagesByConvo(String convoId, String ownerDid) async {
    final query = select(
      dmMessages,
    ).join([innerJoin(profiles, profiles.did.equalsExp(dmMessages.senderDid))]);
    query.where(dmMessages.convoId.equals(convoId) & dmMessages.ownerDid.equals(ownerDid));
    query.orderBy([OrderingTerm.asc(dmMessages.sentAt)]);

    final rows = await query.get();
    return rows.map((row) {
      return DmMessageWithSender(
        message: row.readTable(dmMessages),
        sender: row.readTable(profiles),
      );
    }).toList();
  }

  /// Inserts a local message (from outbox) for immediate display.
  Future<void> insertLocalMessage(DmMessagesCompanion message) async {
    await into(dmMessages).insertOnConflictUpdate(message);
  }

  /// Updates the status of a message.
  Future<void> updateMessageStatus({
    required String messageId,
    required String ownerDid,
    required String status,
  }) async {
    await (update(dmMessages)
          ..where((m) => m.messageId.equals(messageId) & m.ownerDid.equals(ownerDid)))
        .write(DmMessagesCompanion(status: Value(status)));
  }

  /// Deletes a single message by its ID.
  Future<int> deleteMessage(String messageId, String ownerDid) async {
    return (delete(
      dmMessages,
    )..where((m) => m.messageId.equals(messageId) & m.ownerDid.equals(ownerDid))).go();
  }

  /// Gets the most recent message in a conversation.
  Future<DmMessage?> getLatestMessage(String convoId, String ownerDid) async {
    final query = select(dmMessages)
      ..where((m) => m.convoId.equals(convoId) & m.ownerDid.equals(ownerDid))
      ..orderBy([(m) => OrderingTerm.desc(m.sentAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Deletes all messages for a conversation.
  Future<int> deleteMessagesByConvo(String convoId, String ownerDid) async {
    return (delete(
      dmMessages,
    )..where((m) => m.convoId.equals(convoId) & m.ownerDid.equals(ownerDid))).go();
  }

  /// Clears all cached messages for a specific owner.
  Future<int> clearMessages(String ownerDid) async {
    return (delete(dmMessages)..where((m) => m.ownerDid.equals(ownerDid))).go();
  }
}

/// Represents a message with its sender profile.
class DmMessageWithSender {
  DmMessageWithSender({required this.message, required this.sender});

  final DmMessage message;
  final Profile sender;
}
