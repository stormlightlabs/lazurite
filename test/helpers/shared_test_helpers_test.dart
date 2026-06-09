import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart';

import 'assertion_helpers.dart';
import 'connectivity_helpers.dart';
import 'fixtures/auth.dart';
import 'fixtures/graph.dart';
import 'fixtures/messages.dart';
import 'fixtures/network.dart';
import 'fixtures/package_info.dart';
import 'search_helpers.dart';

class _MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class _MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PostSearchFilters());
  });

  group('auth fixtures', () {
    test('build common account token shapes', () {
      expect(testAliceTokens().handle, 'alice.bsky.social');
      expect(testRiverTokens().displayName, 'River Tam');
      expect(testOAuthTokens().authMethod, AuthMethod.oauth);
      expect(testOpaqueOAuthTokens().accessToken, 'opaque-access-token');
      expect(testPdsOAuthTokens(service: 'https://custom.pds').service, 'https://custom.pds');
    });
  });

  group('network fixtures', () {
    test('builds DID documents with PDS service entries', () {
      expect(testPdsService(serviceEndpoint: 'https://pds.example')['type'], 'AtprotoPersonalDataServer');
      expect(testDidDocument(serviceEndpoint: 'https://pds.example')['service'], [
        {'id': '#atproto_pds', 'type': 'AtprotoPersonalDataServer', 'serviceEndpoint': 'https://pds.example'},
      ]);
    });
  });

  group('package info fixture', () {
    test('uses Lazurite defaults with overridable fields', () {
      final info = testPackageInfo(buildNumber: '42');

      expect(info.appName, 'Lazurite');
      expect(info.packageName, 'org.stormlightlabs.lazurite');
      expect(info.buildNumber, '42');
    });
  });

  group('graph fixtures', () {
    test('builds list, list item, and starter pack models', () {
      final listUri = AtUri.parse('at://did:plc:test/app.bsky.graph.list/abc');

      expect(testListView(uri: listUri, name: 'Good Accounts').uri, listUri);
      expect(testListItemView().subject.handle, 'member.bsky.social');
      expect(testStarterPackViewBasic(name: 'Good Pack').record['name'], 'Good Pack');
    });
  });

  group('message fixtures', () {
    test('build direct and group conversation JSON accepted by generated models', () {
      final direct = ConvoView.fromJson(testDirectConvoJson());
      final group = ConvoView.fromJson(testGroupConvoJson());

      expect(direct.kind?.isDirectConvo, isTrue);
      expect(group.kind?.isGroupConvo, isTrue);
      expect(group.kind?.groupConvo?.name, testGroupName);
      expect(group.kind?.groupConvo?.$unknown?['memberLimit'], 50);
    });

    test('build group member, system message, join link, and join request JSON', () {
      final memberPage = testGroupMemberPageJson();
      final systemMessage = SystemMessageView.fromJson(testGroupSystemMessageJson());
      final joinLink = JoinLinkView.fromJson(testJoinLinkJson());
      final joinRequest = JoinRequestView.fromJson(testJoinRequestJson());

      expect(memberPage['members'], isA<List<Map<String, Object?>>>());
      expect(systemMessage.data.isSystemMessageDataMemberJoin, isTrue);
      expect(joinLink.code, testJoinLinkCode);
      expect(joinRequest.convoId, testConvoId);
    });
  });

  group('search helpers', () {
    test('stub search posts and capture filters', () async {
      final repository = _MockSearchRepository();
      const filters = PostSearchFilters(author: 'alice.bsky.social');

      stubSearchPosts(repository);

      final result = await repository.searchPosts(query: 'flutter', filters: filters);

      expect(result.posts, isEmpty);
      expect(captureSearchFilters(repository), [filters]);
    });

    test('stub typeahead and errors', () async {
      final repository = _MockSearchRepository();

      stubTypeahead(
        repository,
        actors: const [ProfileViewBasic(did: 'did:plc:alice', handle: 'alice.bsky.social')],
      );
      expect(await repository.searchActorsTypeahead(query: 'ali'), hasLength(1));

      stubSearchPostsError(repository, Exception('boom'));
      expect(() => repository.searchPosts(query: 'flutter'), throwsException);
    });
  });

  group('connectivity helper', () {
    test('stubs state and stream', () {
      final cubit = _MockConnectivityCubit();

      stubConnectivityCubit(cubit, state: const ConnectivityState.offline());

      expect(cubit.state, const ConnectivityState.offline());
    });
  });

  group('assertion helpers', () {
    testWidgets('assert common account and state copy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                Text('Alice'),
                Text('@alice.bsky.social'),
                Text('Failed to load messages'),
                Text('Retry'),
                Text('No connection'),
                Text('Reconnect to load messages.'),
                Text('A curated list of posts'),
                Text('by @creator.bsky.social'),
                Text('A Member'),
                Text('@member.bsky.social'),
                Text('FEED'),
                Text('News Feed'),
                Text('LIST'),
                Text('Good Accounts'),
              ],
            ),
          ),
        ),
      );

      expectAccountRow(displayName: 'Alice', handle: 'alice.bsky.social');
      expectErrorState('Failed to load messages');
      expectOfflineState('No connection', message: 'Reconnect to load messages.');
      expectListDetailHeader(description: 'A curated list of posts', creatorHandle: 'creator.bsky.social');
      expectListMember(displayName: 'A Member', handle: 'member.bsky.social');
      expectFeedEmbed(name: 'News Feed');
      expectListEmbed(name: 'Good Accounts');
    });
  });
}
