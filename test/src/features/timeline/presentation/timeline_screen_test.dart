import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/timeline/application/timeline_providers.dart';
import 'package:lazurite/src/features/timeline/infrastructure/timeline_repository.dart';
import 'package:lazurite/src/features/timeline/presentation/timeline_screen.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;

  setUp(() {
    mockRepository = MockTimelineRepository();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [timelineRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: TimelineScreen()),
    );
  }

  testWidgets('renders list of posts when data is available', (tester) async {
    final post = Post(
      uri: 'uri1',
      cid: 'cid1',
      authorDid: 'did1',
      record: '{"text": "Hello"}',
      indexedAt: DateTime.now(),
      likeCount: 0,
      replyCount: 0,
      repostCount: 0,
    );
    const author = Profile(
      did: 'did1',
      handle: 'alice',
      displayName: 'Alice',
      description: 'Bio',
      avatar: 'avatar.jpg',
    );
    const item = TimelineItem(postUri: 'uri1', feedKey: 'home', sortKey: '100');

    final feedItem = TimelineFeedItem(post: post, author: author, item: item);

    when(() => mockRepository.watchTimeline(feedKey: 'home')).thenAnswer((_) => Stream.value([feedItem]));

    await tester.pumpWidget(createSubject());
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('pull-to-refresh triggers repository fetch', (tester) async {
    final post = Post(
      uri: 'uri1',
      cid: 'cid1',
      authorDid: 'did1',
      record: '{"text": "Hello"}',
      indexedAt: DateTime.now(),
      likeCount: 0,
      replyCount: 0,
      repostCount: 0,
    );
    const author = Profile(did: 'did1', handle: 'alice');
    const item = TimelineItem(feedKey: 'home', postUri: 'uri1', sortKey: '100');
    final feedItem = TimelineFeedItem(post: post, author: author, item: item);

    when(() => mockRepository.watchTimeline(feedKey: 'home')).thenAnswer((_) => Stream.value([feedItem]));

    when(() => mockRepository.fetchAndCacheTimeline(feedUri: null)).thenAnswer((_) async {});

    await tester.pumpWidget(createSubject());
    await tester.pump();

    await tester.drag(find.text('Hello'), const Offset(0, 300));
    await tester.pumpAndSettle();

    verify(() => mockRepository.fetchAndCacheTimeline(feedUri: null)).called(1);
  });
}
