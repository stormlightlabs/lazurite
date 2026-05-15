import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/search_actors_typeahead.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_list_feed.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_list.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_lists.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_lists_with_membership.dart';
import 'package:poptart_lex/com/atproto/repo/create_record.dart';
import 'package:poptart_lex/com/atproto/repo/delete_record.dart';
import 'package:poptart_lex/com/atproto/repo/put_record.dart';
import 'package:poptart_lex/com/atproto/repo/upload_blob.dart';

void main() {
  late _FakeXrpcTransport transport;
  late ListRepository repository;

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');
  final listItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1');
  final blockUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listblock/block-1');

  setUp(() {
    transport = _FakeXrpcTransport();
    repository = ListRepository(
      bluesky: Bluesky.fromSession(
        _session,
        service: 'bsky.social',
        getClient: transport.get,
        postClient: transport.post,
      ),
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
      transport.getListsResult = GraphGetListsOutput(lists: [listView], cursor: 'cursor-1');

      final result = await repository.getLists(actor: 'did:plc:creator', limit: 25);

      expect(result.lists, [listView]);
      expect(result.cursor, 'cursor-1');
      expect(transport.lastGetListsActor, 'did:plc:creator');
      expect(transport.lastGetListsLimit, 25);
      expect(transport.lastGetListsPurposes?.map((purpose) => purpose.toJson()).toList(), ['curatelist', 'modlist']);
    });

    test('getList returns the hydrated list and members', () async {
      transport.getListResult = GraphGetListOutput(list: listView, items: [listItem]);

      final result = await repository.getList(listUri: listUri);

      expect(result.list, listView);
      expect(result.items, [listItem]);
      expect(transport.lastGetListUri, listUri);
    });

    test('getListFeed returns feed posts and cursor', () async {
      transport.getListFeedResult = FeedGetListFeedOutput(feed: [feedPost], cursor: 'cursor-2');

      final result = await repository.getListFeed(listUri: listUri);

      expect(result.posts, [feedPost]);
      expect(result.cursor, 'cursor-2');
      expect(transport.lastListUri, listUri);
    });

    test('getListsWithMembership returns membership records', () async {
      transport.getListsWithMembershipResult = GraphGetListsWithMembershipOutput(
        listsWithMembership: [ListWithMembership(list: listView, listItem: listItem)],
      );

      final result = await repository.getListsWithMembership(actor: 'did:plc:member-1');

      expect(result.lists.length, 1);
      expect(result.lists.single.listItem, listItem);
      expect(transport.lastGetListsWithMembershipPurposes?.map((purpose) => purpose.toJson()).toList(), [
        'curatelist',
        'modlist',
      ]);
    });

    test('searchActorsTypeahead returns matching actors', () async {
      transport.searchActorsResult = const ActorSearchActorsTypeaheadOutput(
        actors: [ProfileViewBasic(did: 'did:plc:member-1', handle: 'member1.bsky.social')],
      );

      final result = await repository.searchActorsTypeahead(query: 'member', limit: 5);

      expect(result.single.did, 'did:plc:member-1');
      expect(transport.lastQuery, 'member');
      expect(transport.lastLimit, 5);
    });

    test('add and remove list members call the record accessors', () async {
      transport.createdListItemUri = listItemUri;

      final createdUri = await repository.addListItem(listUri: listUri, subjectDid: 'did:plc:member-1');
      await repository.removeListItem(listItemUri: listItemUri);

      expect(createdUri, listItemUri.toString());
      expect(transport.lastCreateCollection, 'app.bsky.graph.listitem');
      expect(transport.lastCreateRecord?['list'], listUri.toString());
      expect(transport.lastCreateRecord?['subject'], 'did:plc:member-1');
      expect(transport.lastDeleteCollection, 'app.bsky.graph.listitem');
      expect(transport.lastDeleteRkey, listItemUri.rkey);
    });

    test('mute and unmute list call graph endpoints', () async {
      await repository.muteList(listUri: listUri);
      await repository.unmuteList(listUri: listUri);

      expect(transport.lastMutedList, listUri);
      expect(transport.lastUnmutedList, listUri);
    });

    test('block and unblock list call listblock accessors', () async {
      transport.createdBlockUri = blockUri;

      final createdUri = await repository.blockList(listUri: listUri);
      await repository.unblockList(blockUri: blockUri);

      expect(createdUri, blockUri.toString());
      expect(transport.lastCreateCollection, 'app.bsky.graph.listblock');
      expect(transport.lastCreateRecord?['subject'], listUri.toString());
      expect(transport.lastDeleteCollection, 'app.bsky.graph.listblock');
      expect(transport.lastDeleteRkey, blockUri.rkey);
    });

    test('uploadListAvatar uploads bytes and returns Blob', () async {
      final bytes = [1, 2, 3, 4];
      final blob = await repository.uploadListAvatar(bytes: bytes, mimeType: 'image/png');

      expect(blob, transport.uploadedBlob);
      expect(transport.lastUploadedBytes, Uint8List.fromList(bytes));
      expect(transport.lastUploadHeaders, containsPair('Content-Type', 'image/png'));
    });

    test('createList creates a record and returns the new URI', () async {
      final createdUri = await repository.createList(
        userDid: 'did:plc:creator',
        name: 'My List',
        purpose: 'app.bsky.graph.defs#curatelist',
        description: 'A great list',
      );

      expect(createdUri, transport.createdListUri);
      expect(transport.lastCreateRepo, 'did:plc:creator');
      expect(transport.lastCreateCollection, 'app.bsky.graph.list');
      expect(transport.lastCreateRecord?[r'$type'], 'app.bsky.graph.list');
      expect(transport.lastCreateRecord?['name'], 'My List');
      expect(transport.lastCreateRecord?['purpose'], 'app.bsky.graph.defs#curatelist');
      expect(transport.lastCreateRecord?['description'], 'A great list');
    });

    test('createList embeds avatar blob when provided', () async {
      const avatarBlob = Blob(
        ref: BlobRef(link: 'bafkreiavatarblob'),
        mimeType: 'image/jpeg',
        size: 1,
      );

      await repository.createList(
        userDid: 'did:plc:creator',
        name: 'List With Avatar',
        purpose: 'app.bsky.graph.defs#modlist',
        avatarBlob: avatarBlob,
      );

      expect(transport.lastCreateRecord?['avatar'], avatarBlob.toJson());
    });

    test('updateList puts an updated record', () async {
      await repository.updateList(
        listUri: listUri,
        userDid: 'did:plc:creator',
        name: 'Updated Name',
        purpose: 'app.bsky.graph.defs#curatelist',
        description: 'Updated description',
      );

      expect(transport.lastPutRepo, 'did:plc:creator');
      expect(transport.lastPutCollection, 'app.bsky.graph.list');
      expect(transport.lastPutRkey, listUri.rkey);
      expect(transport.lastPutRecord?['name'], 'Updated Name');
      expect(transport.lastPutRecord?['description'], 'Updated description');
    });

    test('deleteList deletes the record by rkey', () async {
      await repository.deleteList(listUri: listUri, userDid: 'did:plc:creator');

      expect(transport.lastDeleteRepo, 'did:plc:creator');
      expect(transport.lastDeleteCollection, 'app.bsky.graph.list');
      expect(transport.lastDeleteRkey, listUri.rkey);
    });
  });
}

const _session = Session(
  did: 'did:plc:creator',
  handle: 'creator.bsky.social',
  accessJwt: 'access-token',
  refreshJwt: 'refresh-token',
);

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

class _FakeXrpcTransport {
  GraphGetListsOutput? getListsResult;
  GraphGetListOutput? getListResult;
  FeedGetListFeedOutput? getListFeedResult;
  GraphGetListsWithMembershipOutput? getListsWithMembershipResult;
  ActorSearchActorsTypeaheadOutput? searchActorsResult;

  AtUri createdListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/created-list');
  AtUri createdListItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-created');
  AtUri createdBlockUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listblock/block-created');
  Blob uploadedBlob = const Blob(
    ref: BlobRef(link: 'bafkreitestblobref'),
    mimeType: 'image/jpeg',
    size: 4,
  );

  String? lastGetListsActor;
  int? lastGetListsLimit;
  List<GraphGetListsPurposes>? lastGetListsPurposes;
  AtUri? lastGetListUri;
  AtUri? lastListUri;
  List<GraphGetListsWithMembershipPurposes>? lastGetListsWithMembershipPurposes;
  String? lastQuery;
  int? lastLimit;

  String? lastCreateRepo;
  String? lastCreateCollection;
  Map<String, dynamic>? lastCreateRecord;

  String? lastPutRepo;
  String? lastPutCollection;
  String? lastPutRkey;
  Map<String, dynamic>? lastPutRecord;

  String? lastDeleteRepo;
  String? lastDeleteCollection;
  String? lastDeleteRkey;

  AtUri? lastMutedList;
  AtUri? lastUnmutedList;

  Uint8List? lastUploadedBytes;
  Map<String, String>? lastUploadHeaders;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final query = url.queryParameters;

    switch (url.pathSegments.last) {
      case 'app.bsky.graph.getLists':
        lastGetListsActor = query['actor'];
        lastGetListsLimit = int.tryParse(query['limit'] ?? '');
        lastGetListsPurposes = _getListPurposes(url.queryParametersAll['purposes'] ?? const []);
        return _jsonResponse(url, 'GET', getListsResult!.toJson());
      case 'app.bsky.graph.getList':
        lastGetListUri = AtUri.parse(query['list']!);
        return _jsonResponse(url, 'GET', getListResult!.toJson());
      case 'app.bsky.feed.getListFeed':
        lastListUri = AtUri.parse(query['list']!);
        return _jsonResponse(url, 'GET', getListFeedResult!.toJson());
      case 'app.bsky.graph.getListsWithMembership':
        lastGetListsWithMembershipPurposes = _getMembershipPurposes(url.queryParametersAll['purposes'] ?? const []);
        return _jsonResponse(url, 'GET', getListsWithMembershipResult!.toJson());
      case 'app.bsky.actor.searchActorsTypeahead':
        lastQuery = query['q'];
        lastLimit = int.tryParse(query['limit'] ?? '');
        return _jsonResponse(url, 'GET', searchActorsResult!.toJson());
      default:
        throw StateError('Unexpected GET ${url.path}');
    }
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    switch (url.pathSegments.last) {
      case 'com.atproto.repo.createRecord':
        final input = _decodeJsonBody(body);
        lastCreateRepo = input['repo'] as String?;
        lastCreateCollection = input['collection'] as String?;
        lastCreateRecord = (input['record'] as Map).cast<String, dynamic>();
        return _jsonResponse(
          url,
          'POST',
          RepoCreateRecordOutput(uri: _createdUriFor(lastCreateCollection), cid: 'cid-created').toJson(),
        );
      case 'com.atproto.repo.putRecord':
        final input = _decodeJsonBody(body);
        lastPutRepo = input['repo'] as String?;
        lastPutCollection = input['collection'] as String?;
        lastPutRkey = input['rkey'] as String?;
        lastPutRecord = (input['record'] as Map).cast<String, dynamic>();
        return _jsonResponse(
          url,
          'POST',
          RepoPutRecordOutput(
            uri: AtUri.parse('at://$lastPutRepo/$lastPutCollection/$lastPutRkey'),
            cid: 'cid-put',
          ).toJson(),
        );
      case 'com.atproto.repo.deleteRecord':
        final input = _decodeJsonBody(body);
        lastDeleteRepo = input['repo'] as String?;
        lastDeleteCollection = input['collection'] as String?;
        lastDeleteRkey = input['rkey'] as String?;
        return _jsonResponse(url, 'POST', const RepoDeleteRecordOutput().toJson());
      case 'com.atproto.repo.uploadBlob':
        lastUploadedBytes = Uint8List.fromList((body as List<int>?) ?? const []);
        lastUploadHeaders = headers;
        return _jsonResponse(url, 'POST', RepoUploadBlobOutput(blob: uploadedBlob).toJson());
      case 'app.bsky.graph.muteActorList':
        lastMutedList = AtUri.parse(_decodeJsonBody(body)['list'] as String);
        return _jsonResponse(url, 'POST', const {});
      case 'app.bsky.graph.unmuteActorList':
        lastUnmutedList = AtUri.parse(_decodeJsonBody(body)['list'] as String);
        return _jsonResponse(url, 'POST', const {});
      default:
        throw StateError('Unexpected POST ${url.path}');
    }
  }

  AtUri _createdUriFor(String? collection) {
    return switch (collection) {
      'app.bsky.graph.list' => createdListUri,
      'app.bsky.graph.listitem' => createdListItemUri,
      'app.bsky.graph.listblock' => createdBlockUri,
      _ => AtUri.parse('at://did:plc:creator/${collection ?? 'unknown'}/created'),
    };
  }

  List<GraphGetListsPurposes> _getListPurposes(List<String> values) {
    return values.map((value) => GraphGetListsPurposes.valueOf(value)!).toList(growable: false);
  }

  List<GraphGetListsWithMembershipPurposes> _getMembershipPurposes(List<String> values) {
    return values.map((value) => GraphGetListsWithMembershipPurposes.valueOf(value)!).toList(growable: false);
  }

  Map<String, dynamic> _decodeJsonBody(Object? body) {
    if (body is String) {
      return (jsonDecode(body) as Map).cast<String, dynamic>();
    }

    if (body == null) {
      return const {};
    }

    throw ArgumentError.value(body, 'body', 'Expected a JSON string body.');
  }

  http.Response _jsonResponse(Uri url, String method, Map<String, dynamic> body) {
    return http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
      request: http.Request(method, url),
    );
  }
}
