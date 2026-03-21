import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:bluesky/app_bsky_graph_getlists.dart';
import 'package:bluesky/app_bsky_graph_getlistswithmembership.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

void main() {
  late _FakeGraphService graph;
  late _FakeFeedService feed;
  late _FakeActorService actor;
  late ListRepository repository;

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');
  final listItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1');
  final blockUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listblock/block-1');

  setUp(() {
    graph = _FakeGraphService();
    feed = _FakeFeedService();
    actor = _FakeActorService();
    repository = ListRepository(
      bluesky: _FakeBlueskyClient(graph: graph, feed: feed, actor: actor),
    );
  });

  group('ListRepository', () {
    final listView = _buildListView(listUri);
    final listItem = ListItemView(
      uri: listItemUri,
      subject: const ProfileView(did: 'did:plc:member-1', handle: 'member1.bsky.social'),
    );
    final feedPost = FeedViewPost(
      post: PostView(
        uri: AtUri.parse('at://did:plc:member-1/app.bsky.feed.post/post-1'),
        cid: 'cid-post',
        author: const ProfileViewBasic(did: 'did:plc:member-1', handle: 'member1.bsky.social'),
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'Hello from a list',
          'createdAt': DateTime.utc(2026, 3, 21).toIso8601String(),
        },
        indexedAt: DateTime.utc(2026, 3, 21),
      ),
    );

    test('getLists requests curation and moderation lists by default', () async {
      graph.getListsResult = _FakeListsData(lists: [listView], cursor: 'cursor-1');

      final result = await repository.getLists(actor: 'did:plc:creator', limit: 25);

      expect(result.lists, [listView]);
      expect(result.cursor, 'cursor-1');
      expect(graph.lastGetListsActor, 'did:plc:creator');
      expect(graph.lastGetListsLimit, 25);
      expect(graph.lastGetListsPurposes?.map((purpose) => purpose.toJson()).toList(), ['curatelist', 'modlist']);
    });

    test('getList returns the hydrated list and members', () async {
      graph.getListResult = _FakeListData(list: listView, items: [listItem], cursor: null);

      final result = await repository.getList(listUri: listUri);

      expect(result.list, listView);
      expect(result.items, [listItem]);
      expect(graph.lastGetListUri, listUri);
    });

    test('getListFeed returns feed posts and cursor', () async {
      feed.getListFeedResult = _FakeListFeedData(feed: [feedPost], cursor: 'cursor-2');

      final result = await repository.getListFeed(listUri: listUri);

      expect(result.posts, [feedPost]);
      expect(result.cursor, 'cursor-2');
      expect(feed.lastListUri, listUri);
    });

    test('getListsWithMembership returns membership records', () async {
      graph.getListsWithMembershipResult = _FakeListsWithMembershipData(
        listsWithMembership: [ListWithMembership(list: listView, listItem: listItem)],
        cursor: null,
      );

      final result = await repository.getListsWithMembership(actor: 'did:plc:member-1');

      expect(result.lists.length, 1);
      expect(result.lists.single.listItem, listItem);
      expect(graph.lastGetListsWithMembershipPurposes?.map((purpose) => purpose.toJson()).toList(), [
        'curatelist',
        'modlist',
      ]);
    });

    test('searchActorsTypeahead returns matching actors', () async {
      actor.searchActorsResult = const _FakeActorsData(
        actors: [ProfileViewBasic(did: 'did:plc:member-1', handle: 'member1.bsky.social')],
      );

      final result = await repository.searchActorsTypeahead(query: 'member', limit: 5);

      expect(result.single.did, 'did:plc:member-1');
      expect(actor.lastQuery, 'member');
      expect(actor.lastLimit, 5);
    });

    test('add and remove list members call the record accessors', () async {
      graph.listitem.createdUri = listItemUri;

      final createdUri = await repository.addListItem(listUri: listUri, subjectDid: 'did:plc:member-1');
      await repository.removeListItem(listItemUri: listItemUri);

      expect(createdUri, listItemUri.toString());
      expect(graph.listitem.lastCreatedList, listUri);
      expect(graph.listitem.lastCreatedSubject, 'did:plc:member-1');
      expect(graph.listitem.lastDeletedRkey, listItemUri.rkey);
    });

    test('mute and unmute list call graph endpoints', () async {
      await repository.muteList(listUri: listUri);
      await repository.unmuteList(listUri: listUri);

      expect(graph.lastMutedList, listUri);
      expect(graph.lastUnmutedList, listUri);
    });

    test('block and unblock list call listblock accessors', () async {
      graph.listblock.createdUri = blockUri;

      final createdUri = await repository.blockList(listUri: listUri);
      await repository.unblockList(blockUri: blockUri);

      expect(createdUri, blockUri.toString());
      expect(graph.listblock.lastCreatedSubject, listUri);
      expect(graph.listblock.lastDeletedRkey, blockUri.rkey);
    });
  });
}

ListView _buildListView(AtUri uri) {
  return ListView(
    uri: uri,
    cid: 'cid-${uri.rkey}',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: 'Core List',
    purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsCuratelist),
    indexedAt: DateTime.utc(2026, 3, 21),
  );
}

class _FakeBlueskyClient {
  _FakeBlueskyClient({required this.graph, required this.feed, required this.actor});

  final _FakeGraphService graph;
  final _FakeFeedService feed;
  final _FakeActorService actor;
}

class _FakeGraphService {
  _FakeGraphService() : listitem = _FakeListitemAccessor(), listblock = _FakeListblockAccessor();

  _FakeListsData? getListsResult;
  _FakeListData? getListResult;
  _FakeListsWithMembershipData? getListsWithMembershipResult;

  String? lastGetListsActor;
  int? lastGetListsLimit;
  List<GraphGetListsPurposes>? lastGetListsPurposes;
  AtUri? lastGetListUri;
  AtUri? lastMutedList;
  AtUri? lastUnmutedList;
  List<GraphGetListsWithMembershipPurposes>? lastGetListsWithMembershipPurposes;

  final _FakeListitemAccessor listitem;
  final _FakeListblockAccessor listblock;

  Future<_FakeResponse<_FakeListsData>> getLists({
    required String actor,
    int? limit,
    String? cursor,
    List<GraphGetListsPurposes>? purposes,
    Map<String, String>? $headers,
  }) async {
    lastGetListsActor = actor;
    lastGetListsLimit = limit;
    lastGetListsPurposes = purposes;
    return _FakeResponse(getListsResult!);
  }

  Future<_FakeResponse<_FakeListData>> getList({
    required AtUri list,
    int? limit,
    String? cursor,
    Map<String, String>? $headers,
  }) async {
    lastGetListUri = list;
    return _FakeResponse(getListResult!);
  }

  Future<_FakeResponse<_FakeListsWithMembershipData>> getListsWithMembership({
    required String actor,
    int? limit,
    String? cursor,
    List<GraphGetListsWithMembershipPurposes>? purposes,
    Map<String, String>? $headers,
  }) async {
    lastGetListsWithMembershipPurposes = purposes;
    return _FakeResponse(getListsWithMembershipResult!);
  }

  Future<void> muteActorList({required AtUri list, Map<String, String>? $headers}) async {
    lastMutedList = list;
  }

  Future<void> unmuteActorList({required AtUri list, Map<String, String>? $headers}) async {
    lastUnmutedList = list;
  }
}

class _FakeFeedService {
  _FakeListFeedData? getListFeedResult;
  AtUri? lastListUri;

  Future<_FakeResponse<_FakeListFeedData>> getListFeed({
    required AtUri list,
    int? limit,
    String? cursor,
    Map<String, String>? $headers,
  }) async {
    lastListUri = list;
    return _FakeResponse(getListFeedResult!);
  }
}

class _FakeActorService {
  _FakeActorsData? searchActorsResult;
  String? lastQuery;
  int? lastLimit;

  Future<_FakeResponse<_FakeActorsData>> searchActorsTypeahead({
    required String q,
    int? limit,
    Map<String, String>? $headers,
  }) async {
    lastQuery = q;
    lastLimit = limit;
    return _FakeResponse(searchActorsResult!);
  }
}

class _FakeListitemAccessor {
  AtUri createdUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-created');
  AtUri? lastCreatedList;
  String? lastCreatedSubject;
  String? lastDeletedRkey;

  Future<_FakeResponse<_FakeUriData>> create({
    required String subject,
    required AtUri list,
    DateTime? createdAt,
  }) async {
    lastCreatedList = list;
    lastCreatedSubject = subject;
    return _FakeResponse(_FakeUriData(createdUri));
  }

  Future<void> delete({required String rkey}) async {
    lastDeletedRkey = rkey;
  }
}

class _FakeListblockAccessor {
  AtUri createdUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listblock/block-created');
  AtUri? lastCreatedSubject;
  String? lastDeletedRkey;

  Future<_FakeResponse<_FakeUriData>> create({required AtUri subject, DateTime? createdAt}) async {
    lastCreatedSubject = subject;
    return _FakeResponse(_FakeUriData(createdUri));
  }

  Future<void> delete({required String rkey}) async {
    lastDeletedRkey = rkey;
  }
}

class _FakeResponse<T> {
  _FakeResponse(this.data);

  final T data;
}

class _FakeListsData {
  const _FakeListsData({required this.lists, this.cursor});

  final List<ListView> lists;
  final String? cursor;
}

class _FakeListData {
  const _FakeListData({required this.list, required this.items, this.cursor});

  final ListView list;
  final List<ListItemView> items;
  final String? cursor;
}

class _FakeListsWithMembershipData {
  const _FakeListsWithMembershipData({required this.listsWithMembership, this.cursor});

  final List<ListWithMembership> listsWithMembership;
  final String? cursor;
}

class _FakeListFeedData {
  const _FakeListFeedData({required this.feed, this.cursor});

  final List<FeedViewPost> feed;
  final String? cursor;
}

class _FakeActorsData {
  const _FakeActorsData({required this.actors});

  final List<ProfileViewBasic> actors;
}

class _FakeUriData {
  const _FakeUriData(this.uri);

  final AtUri uri;
}
