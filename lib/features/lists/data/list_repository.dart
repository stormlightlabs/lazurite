import 'dart:typed_data';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_lists.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_lists_with_membership.dart';
import 'package:bluesky_poptart/app/bsky/graph/list.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class ListRepository {
  ListRepository({
    required Bluesky bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<ListsResult> getLists({
    required String actor,
    String? cursor,
    int limit = 50,
    bool includeReference = false,
  }) async {
    final response = await _bluesky.graph.getLists(
      actor: actor,
      cursor: cursor,
      limit: limit,
      purposes: includeReference ? null : _listPurposes,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.graph.getLists',
        await _moderationService?.headersForRequest(),
      ),
    );

    return ListsResult(lists: _filterLists(response.data.lists), cursor: response.data.cursor);
  }

  Future<ListDetailResult> getList({required AtUri listUri, String? cursor, int limit = 50}) async {
    final response = await _bluesky.graph.getList(
      list: listUri,
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.graph.getList',
        await _moderationService?.headersForRequest(),
      ),
    );

    return ListDetailResult(
      list: response.data.list,
      items: _filterListItems(response.data.items),
      cursor: response.data.cursor,
    );
  }

  Future<ListFeedResult> getListFeed({required AtUri listUri, String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getListFeed(
      list: listUri,
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.feed.getListFeed',
        await _moderationService?.headersForRequest(),
      ),
    );

    return ListFeedResult(posts: _filterFeedPosts(response.data.feed), cursor: response.data.cursor);
  }

  Future<ListsWithMembershipResult> getListsWithMembership({
    required String actor,
    String? cursor,
    int limit = 50,
  }) async {
    final response = await _bluesky.graph.getListsWithMembership(
      actor: actor,
      cursor: cursor,
      limit: limit,
      purposes: _membershipPurposes,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.graph.getListsWithMembership',
        await _moderationService?.headersForRequest(),
      ),
    );

    return ListsWithMembershipResult(
      lists: response.data.listsWithMembership.where((entry) => !_shouldFilterList(entry.list)).toList(growable: false),
      cursor: response.data.cursor,
    );
  }

  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 10}) async {
    final response = await _bluesky.actor.searchActorsTypeahead(
      q: query,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.actor.searchActorsTypeahead',
        await _moderationService?.headersForRequest(),
      ),
    );

    return _filterProfiles(response.data.actors);
  }

  Future<String> addListItem({required AtUri listUri, required String subjectDid}) async {
    final response = await _bluesky.graph.listitem.create(
      list: listUri,
      subject: subjectDid,
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );

    return response.data.uri.toString();
  }

  Future<void> removeListItem({required AtUri listItemUri}) async {
    await _bluesky.graph.listitem.delete(
      rkey: listItemUri.rkey,
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );
  }

  Future<void> muteList({required AtUri listUri}) async {
    await _bluesky.graph.muteActorList(
      list: listUri,
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );
  }

  Future<void> unmuteList({required AtUri listUri}) async {
    await _bluesky.graph.unmuteActorList(
      list: listUri,
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );
  }

  Future<String> blockList({required AtUri listUri}) async {
    final response = await _bluesky.graph.listblock.create(
      subject: listUri,
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );

    return response.data.uri.toString();
  }

  Future<void> unblockList({required AtUri blockUri}) async {
    await _bluesky.graph.listblock.delete(
      rkey: blockUri.rkey,
      $headers: _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest()),
    );
  }

  Future<Blob?> uploadListAvatar({required List<int> bytes, String mimeType = 'image/jpeg'}) async {
    final response = await _bluesky.atproto.repo.uploadBlob(
      bytes: Uint8List.fromList(bytes),
      $headers: {'Content-Type': mimeType},
    );
    return response.data.blob;
  }

  Future<AtUri> createList({
    required String userDid,
    required String name,
    required String purpose,
    String? description,
    Blob? avatarBlob,
  }) async {
    final record = GraphListRecord(
      purpose: _listPurposeFromString(purpose),
      name: name,
      description: _trimOptional(description),
      avatar: avatarBlob,
      createdAt: DateTime.now().toUtc(),
    );

    final response = await _bluesky.atproto.repo.createRecord(
      repo: userDid,
      collection: 'app.bsky.graph.list',
      record: record.toJson(),
    );
    return response.data.uri;
  }

  Future<void> updateList({
    required AtUri listUri,
    required String userDid,
    required String name,
    required String purpose,
    String? description,
    Blob? avatarBlob,
  }) async {
    final record = GraphListRecord(
      purpose: _listPurposeFromString(purpose),
      name: name,
      description: _trimOptional(description),
      avatar: avatarBlob,
      createdAt: DateTime.now().toUtc(),
    );

    await _bluesky.atproto.repo.putRecord(
      repo: userDid,
      collection: 'app.bsky.graph.list',
      rkey: listUri.rkey,
      record: record.toJson(),
    );
  }

  Future<void> deleteList({required AtUri listUri, required String userDid}) async {
    await _bluesky.atproto.repo.deleteRecord(repo: userDid, collection: 'app.bsky.graph.list', rkey: listUri.rkey);
  }

  List<ListView> _filterLists(List<ListView> lists) {
    return lists.where((list) => !_shouldFilterList(list)).toList(growable: false);
  }

  List<ListItemView> _filterListItems(List<ListItemView> items) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return items;
    }

    return items.where((item) => !moderationService.shouldFilterProfileInList(item.subject)).toList(growable: false);
  }

  List<ProfileViewBasic> _filterProfiles(List<ProfileViewBasic> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return profiles;
    }

    return profiles
        .where((profile) => !moderationService.shouldFilterProfileBasicInList(profile))
        .toList(growable: false);
  }

  List<FeedViewPost> _filterFeedPosts(List<FeedViewPost> posts) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return posts;
    }

    return posts.where((post) => !moderationService.shouldFilterFeedViewPostInList(post)).toList(growable: false);
  }

  bool _shouldFilterList(ListView list) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return false;
    }

    return moderationService.shouldFilterProfileInList(list.creator);
  }

  static const List<GraphGetListsPurposes> _listPurposes = [
    GraphGetListsPurposes.knownValue(data: KnownGraphGetListsPurposes.curatelist),
    GraphGetListsPurposes.knownValue(data: KnownGraphGetListsPurposes.modlist),
  ];

  static const List<GraphGetListsWithMembershipPurposes> _membershipPurposes = [
    GraphGetListsWithMembershipPurposes.knownValue(data: KnownGraphGetListsWithMembershipPurposes.curatelist),
    GraphGetListsWithMembershipPurposes.knownValue(data: KnownGraphGetListsWithMembershipPurposes.modlist),
  ];

  ListPurpose _listPurposeFromString(String value) {
    final purpose = ListPurpose.valueOf(value.trim());
    if (purpose == null) {
      throw ArgumentError.value(value, 'purpose', 'List purpose is required.');
    }
    return purpose;
  }

  String? _trimOptional(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class ListsResult {
  const ListsResult({required this.lists, this.cursor});

  final List<ListView> lists;
  final String? cursor;
}

class ListDetailResult {
  const ListDetailResult({required this.list, required this.items, this.cursor});

  final ListView list;
  final List<ListItemView> items;
  final String? cursor;
}

class ListFeedResult {
  const ListFeedResult({required this.posts, this.cursor});

  final List<FeedViewPost> posts;
  final String? cursor;
}

class ListsWithMembershipResult {
  const ListsWithMembershipResult({required this.lists, this.cursor});

  final List<ListWithMembership> lists;
  final String? cursor;
}
