import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSessionStorage mockSessionStorage;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    mockProfileRepository = MockProfileRepository();
  });

  Widget createSubject({required String did, List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(mockSessionStorage),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ...overrides,
      ],
      child: MaterialApp(home: ProfilePage(did: did)),
    );
  }

  group('Profile Screen Regression Tests', () {
    testWidgets('shows "Follows you" indicator when profile follows viewer', (tester) async {
      final profile = ProfileData(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
        viewerFollowedBy: true,
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:other',
          overrides: [
            profileProvider('did:plc:other').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider('did:plc:other').overrideWith(() => MockAuthorFeedNotifier([])),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Follows you'), findsOneWidget);
    });

    testWidgets('hides Pinned Post header and card when pinned post fails to load', (
      tester,
    ) async {
      final profile = ProfileData(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        pinnedPostUri: 'at://did:plc:test/app.bsky.feed.post/deleted',
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:test',
          overrides: [
            profileProvider('did:plc:test').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider('did:plc:test').overrideWith(() => MockAuthorFeedNotifier([])),
            pinnedPostProvider(
              'at://did:plc:test/app.bsky.feed.post/deleted',
            ).overrideWith((ref) => Future.value(null)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pinned Post'), findsNothing);
    });

    testWidgets('shows "No posts yet" when author has no posts but has a deleted pinned post', (
      tester,
    ) async {
      final profile = ProfileData(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        pinnedPostUri: 'at://did:plc:test/app.bsky.feed.post/deleted',
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:test',
          overrides: [
            profileProvider('did:plc:test').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider('did:plc:test').overrideWith(() => MockAuthorFeedNotifier([])),
            pinnedPostProvider(
              'at://did:plc:test/app.bsky.feed.post/deleted',
            ).overrideWith((ref) => Future.value(null)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('shows "Unfollow" text when following a profile', (tester) async {
      final profile = ProfileData(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
        viewerFollowing: true,
        viewerFollowUri: 'at://did:plc:viewer/app.bsky.graph.follow/123',
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:other',
          overrides: [
            profileProvider('did:plc:other').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider('did:plc:other').overrideWith(() => MockAuthorFeedNotifier([])),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unfollow'), findsOneWidget);
    });

    testWidgets('shows both "Unfollow" and "Follows you" for mutual follow', (tester) async {
      final profile = ProfileData(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
        viewerFollowing: true,
        viewerFollowUri: 'at://did:plc:viewer/app.bsky.graph.follow/123',
        viewerFollowedBy: true,
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createSubject(
          did: 'did:plc:other',
          overrides: [
            profileProvider('did:plc:other').overrideWith(() => MockProfileNotifier(profile)),
            authorFeedProvider('did:plc:other').overrideWith(() => MockAuthorFeedNotifier([])),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unfollow'), findsOneWidget);
      expect(find.text('Follows you'), findsOneWidget);
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
  bool get hasMore => false;
}
