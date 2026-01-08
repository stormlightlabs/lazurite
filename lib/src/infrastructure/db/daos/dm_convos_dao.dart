import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dm_convos_dao.g.dart';

/// DAO for managing cached DM conversations.
///
/// Handles storage and retrieval of conversations from
/// chat.bsky.convo.listConvos API.
@DriftAccessor(tables: [DmConvos, Profiles])
class DmConvosDao extends DatabaseAccessor<AppDatabase> with _$DmConvosDaoMixin {
  DmConvosDao(super.db);

  /// Inserts or updates a batch of conversations.
  Future<void> insertConvosBatch({
    required List<DmConvosCompanion> newConvos,
    required List<ProfilesCompanion> newProfiles,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(dmConvos, newConvos, mode: InsertMode.insertOrReplace);
      });
    });
  }

  /// Gets a stream of all conversations sorted by last message time.
  Stream<List<DmConvoWithMembers>> watchConversations() {
    return select(dmConvos).watch().asyncMap((convos) async {
      final result = <DmConvoWithMembers>[];
      for (final convo in convos) {
        final memberDids = _parseMemberDids(convo.membersJson);
        if (memberDids.isEmpty) continue;

        final memberProfiles = await (select(
          profiles,
        )..where((p) => p.did.isIn(memberDids))).get();

        result.add(DmConvoWithMembers(convo: convo, members: memberProfiles));
      }

      result.sort((a, b) {
        final aTime = a.convo.lastMessageAt;
        final bTime = b.convo.lastMessageAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      return result;
    });
  }

  /// Gets a single conversation by ID.
  Future<DmConvoWithMembers?> getConvo(String convoId) async {
    final convo = await (select(
      dmConvos,
    )..where((c) => c.convoId.equals(convoId))).getSingleOrNull();
    if (convo == null) return null;

    final memberDids = _parseMemberDids(convo.membersJson);
    final memberProfiles = await (select(profiles)..where((p) => p.did.isIn(memberDids))).get();

    return DmConvoWithMembers(convo: convo, members: memberProfiles);
  }

  /// Updates the read state for a conversation.
  Future<void> updateReadState({
    required String convoId,
    required String lastReadMessageId,
    required int unreadCount,
  }) async {
    await (update(dmConvos)..where((c) => c.convoId.equals(convoId))).write(
      DmConvosCompanion(
        lastReadMessageId: Value(lastReadMessageId),
        unreadCount: Value(unreadCount),
      ),
    );
  }

  /// Updates the last message preview for a conversation.
  Future<void> updateLastMessage({
    required String convoId,
    required String? lastMessageText,
    required DateTime? lastMessageAt,
  }) async {
    await (update(dmConvos)..where((c) => c.convoId.equals(convoId))).write(
      DmConvosCompanion(
        lastMessageText: Value(lastMessageText),
        lastMessageAt: Value(lastMessageAt),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks a conversation as accepted.
  Future<void> acceptConvo(String convoId) async {
    await (update(dmConvos)..where((c) => c.convoId.equals(convoId))).write(
      const DmConvosCompanion(isAccepted: Value(true)),
    );
  }

  /// Clears all cached conversations.
  Future<void> clearConversations() async {
    await delete(dmConvos).go();
  }

  /// Parses member DIDs from JSON array string.
  List<String> _parseMemberDids(String membersJson) {
    try {
      final list = membersJson.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      if (list.isEmpty) return [];
      return list.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}

/// Represents a conversation with its member profiles.
class DmConvoWithMembers {
  DmConvoWithMembers({required this.convo, required this.members});

  final DmConvo convo;
  final List<Profile> members;
}
