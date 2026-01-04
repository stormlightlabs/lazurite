import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'timeline_dao.g.dart';

@DriftAccessor(tables: [Posts, Profiles, TimelineItems, FeedCursors])
class TimelineDao extends DatabaseAccessor<AppDatabase> with _$TimelineDaoMixin {
  TimelineDao(super.db);

  /// Inserts or updates a batch of posts and their authors, and links them to the timeline.
  /// Also updates the cursor for the given [feedKey].
  Future<void> insertTimeline({
    required String feedKey,
    required List<PostInsert> newPosts,
    required List<ProfileInsert> newProfiles,
    required String? nextCursor,
  }) async {
    await batch((batch) {
      batch.insertAll(
        profiles,
        newProfiles.map(
          (p) => ProfilesCompanion.insert(
            did: p.did,
            handle: p.handle,
            displayName: Value(p.displayName),
            description: Value(p.description),
            avatar: Value(p.avatar),
            indexedAt: Value(p.indexedAt),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );

      batch.insertAll(
        posts,
        newPosts.map(
          (p) => PostsCompanion.insert(
            uri: p.uri,
            cid: p.cid,
            authorDid: p.authorDid,
            record: p.record,
            indexedAt: Value(p.indexedAt),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> insertTimelineBatch({
    required List<PostsCompanion> newPosts,
    required List<ProfilesCompanion> newProfiles,
    required List<TimelineItemsCompanion> newItems,
    required String feedKey,
    String? newCursor,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(posts, newPosts, mode: InsertMode.insertOrReplace);
        batch.insertAll(timelineItems, newItems, mode: InsertMode.insertOrReplace);
      });

      if (newCursor != null) {
        await into(feedCursors).insertOnConflictUpdate(
          FeedCursorsCompanion.insert(
            feedKey: feedKey,
            cursor: newCursor,
            lastUpdated: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Get stream of timeline items
  Stream<List<TimelineFeedItem>> watchTimeline(String feedKey) {
    final query = select(timelineItems).join([
      innerJoin(posts, posts.uri.equalsExp(timelineItems.postUri)),
      innerJoin(profiles, profiles.did.equalsExp(posts.authorDid)),
    ]);

    query.where(timelineItems.feedKey.equals(feedKey));
    query.orderBy([OrderingTerm.desc(timelineItems.sortKey)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TimelineFeedItem(
          post: row.readTable(posts),
          author: row.readTable(profiles),
          item: row.readTable(timelineItems),
        );
      }).toList();
    });
  }

  Future<String?> getCursor(String feedKey) async {
    final query = select(feedCursors)..where((t) => t.feedKey.equals(feedKey));
    final result = await query.getSingleOrNull();
    return result?.cursor;
  }

  Future<void> clearTimeline(String feedKey) async {
    await (delete(timelineItems)..where((t) => t.feedKey.equals(feedKey))).go();
  }
}

class TimelineFeedItem {
  TimelineFeedItem({required this.post, required this.author, required this.item});

  final Post post;
  final Profile author;
  final TimelineItem item;
}

class PostInsert {
  PostInsert({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.record,
    this.indexedAt,
  });

  final String uri;
  final String cid;
  final String authorDid;
  final String record;
  final DateTime? indexedAt;
}

class ProfileInsert {
  ProfileInsert({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.indexedAt,
  });

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final DateTime? indexedAt;
}
