import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/cubit/similar_posts_cubit.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/similar_posts_section.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/feed.dart';

class MockBluesky extends Mock implements Bluesky {}

void main() {
  testWidgets('keeps similar posts collapsed until requested', (tester) async {
    await tester.pumpWidget(_TestApp(repository: _repository(posts: [_post('at://did:plc:one/app.bsky.feed.post/a')])));

    expect(find.text('Similar posts'), findsOneWidget);
    expect(find.text('Liked by people who liked this post'), findsOneWidget);
    expect(find.text('Show similar posts'), findsOneWidget);
    expect(find.text('author.example'), findsNothing);

    await tester.tap(find.text('Show similar posts'));
    await tester.pumpAndSettle();

    expect(find.text('author.example'), findsOneWidget);
    final card = tester.widget<CompactPostCard>(find.byType(CompactPostCard));
    expect(card.contentPadding, const EdgeInsets.fromLTRB(16, 14, 16, 14));
  });

  testWidgets('places Show more in the section header instead of below the cards', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        repository: _repository(posts: [_post('at://did:plc:one/app.bsky.feed.post/a')], cursor: 'next'),
      ),
    );

    await tester.tap(find.text('Show similar posts'));
    await tester.pumpAndSettle();

    final showMoreTop = tester.getTopLeft(find.widgetWithText(TextButton, 'Show more')).dy;
    final cardBottom = tester.getBottomLeft(find.byType(CompactPostCard)).dy;
    expect(showMoreTop, lessThan(cardBottom));
  });

  testWidgets('keeps loaded similar post cards at a fixed height with scrollable content', (tester) async {
    final longPost = _post(
      'at://did:plc:one/app.bsky.feed.post/a',
      text: List.filled(24, 'A long similar post sentence.').join(' '),
    );

    await tester.pumpWidget(_TestApp(repository: _repository(posts: [longPost])));

    await tester.tap(find.text('Show similar posts'));
    await tester.pumpAndSettle();

    final scrollable = find.byKey(similarPostCardScrollKey);
    expect(scrollable, findsOneWidget);
    expect(tester.getSize(scrollable).height, 220);

    final scrollableState = tester.state<ScrollableState>(find.descendant(of: scrollable, matching: find.byType(Scrollable)));
    expect(scrollableState.position.maxScrollExtent, greaterThan(0));

    await tester.drag(scrollable, const Offset(0, -80));
    await tester.pump();
    expect(scrollableState.position.pixels, greaterThan(0));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.repository});

  final SimilarPostsRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => SimilarPostsCubit(repository: repository),
          child: const SimilarPostsSection(postUri: 'at://did:plc:seed/app.bsky.feed.post/root'),
        ),
      ),
    );
  }
}

SimilarPostsRepository _repository({required List<PostView> posts, String? cursor}) => SimilarPostsRepository(
  bluesky: MockBluesky(),
  constellationClient: ConstellationClient(),
  likerDidLoader: (_, _, _) async => (dids: ['did:plc:liker'], cursor: cursor),
  recentLikedPostUriLoader: (_, _) async => posts.map((post) => post.uri.toString()).toList(),
  postHydrator: (_) async => posts,
);

PostView _post(String uri, {String text = 'similar post body'}) => testPostView(
  uri: uri,
  cid: 'cid-$uri',
  author: testProfileViewBasic(handle: 'author.example'),
  record: testPostRecordJson(text: text, createdAt: DateTime.utc(2026, 5, 23)),
  indexedAt: DateTime.utc(2026, 5, 23),
);
