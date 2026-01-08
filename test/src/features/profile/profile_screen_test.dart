import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockSessionStorage mockSessionStorage;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    mockProfileRepository = MockProfileRepository();
  });

  Widget createSubject({
    required String did,
    bool isCurrentUser = false,
    List overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(mockSessionStorage),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ...overrides,
      ],
      child: MaterialApp(home: ProfilePage(did: did)),
    );
  }

  group('ProfileScreen', () {
    testWidgets('renders app bar with profile title', (tester) async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSubject(did: 'did:plc:test'));
      await tester.pump();

      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('shows sign in message when not authenticated', (tester) async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sign in to view your profile'), findsOneWidget);
    });

    testWidgets('displays pinned post when present', (tester) async {
      final profile = ProfileData(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        displayName: 'Test User',
        pinnedPostUri: 'at://did:plc:test/app.bsky.feed.post/pinned',
      );

      final pinnedPost = FeedItem(
        uri: 'at://did:plc:test/app.bsky.feed.post/pinned',
        cid: 'cid1',
        authorDid: 'did:plc:test',
        authorHandle: 'test.bsky.social',
        text: 'This is a pinned post',
        indexedAt: DateTime.now(),
      );

      final feedItems = [
        FeedItem(
          uri: 'at://did:plc:test/app.bsky.feed.post/1',
          cid: 'cid2',
          authorDid: 'did:plc:test',
          authorHandle: 'test.bsky.social',
          text: 'Regular post',
          indexedAt: DateTime.now(),
        ),
      ];

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:test',
          overrides: [
            profileProvider('did:plc:test').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider(
              'did:plc:test',
            ).overrideWith(() => MockAuthorFeedNotifier(feedItems)),
            pinnedPostProvider(
              'at://did:plc:test/app.bsky.feed.post/pinned',
            ).overrideWith((ref) => Future.value(pinnedPost)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pinned Post'), findsOneWidget);
      expect(find.text('This is a pinned post'), findsOneWidget);
      expect(find.text('Regular post'), findsOneWidget);
    });

    testWidgets('does not duplicate pinned post in feed', (tester) async {
      final profile = ProfileData(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        displayName: 'Test User',
        pinnedPostUri: 'at://did:plc:test/app.bsky.feed.post/pinned',
      );

      final pinnedPost = FeedItem(
        uri: 'at://did:plc:test/app.bsky.feed.post/pinned',
        cid: 'cid1',
        authorDid: 'did:plc:test',
        authorHandle: 'test.bsky.social',
        text: 'This is a pinned post',
        indexedAt: DateTime.now(),
      );

      final feedItems = [
        pinnedPost,
        FeedItem(
          uri: 'at://did:plc:test/app.bsky.feed.post/1',
          cid: 'cid2',
          authorDid: 'did:plc:test',
          authorHandle: 'test.bsky.social',
          text: 'Regular post',
          indexedAt: DateTime.now(),
        ),
      ];

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:test',
          overrides: [
            profileProvider('did:plc:test').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider(
              'did:plc:test',
            ).overrideWith(() => MockAuthorFeedNotifier(feedItems)),
            pinnedPostProvider(
              'at://did:plc:test/app.bsky.feed.post/pinned',
            ).overrideWith((ref) => Future.value(pinnedPost)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pinned Post'), findsOneWidget);
      expect(find.text('This is a pinned post'), findsOneWidget);
      expect(find.text('Regular post'), findsOneWidget);
    });
  });
}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier(this._data);
  final ProfileData _data;

  @override
  Future<ProfileData> build(String actor) async => _data;
}

class MockAuthorFeedNotifier extends AuthorFeedNotifier {
  MockAuthorFeedNotifier(this._items);
  final List<FeedItem> _items;

  @override
  Future<List<FeedItem>> build(String actor) async => _items;

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}

  @override
  bool get hasMore => false;
}
