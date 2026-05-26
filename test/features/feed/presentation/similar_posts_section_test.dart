import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/cubit/similar_posts_cubit.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/similar_posts_section.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/feed_fixtures.dart';

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

SimilarPostsRepository _repository({required List<PostView> posts}) => SimilarPostsRepository(
  bluesky: MockBluesky(),
  constellationClient: ConstellationClient(),
  relationshipLoader: (_, _, _) async =>
      (items: posts.map((post) => _item(post.uri.toString())).toList(), cursor: null),
  postHydrator: (_) async => posts,
);

ManyToManyItem _item(String otherSubject) => ManyToManyItem(
  linkRecord: const ConstellationLinkRecord(did: 'did:plc:liker', collection: 'app.bsky.feed.like', rkey: 'like'),
  otherSubject: otherSubject,
);

PostView _post(String uri) => testPostView(
  uri: uri,
  cid: 'cid-$uri',
  author: testProfileViewBasic(handle: 'author.example'),
  record: testPostRecordJson(text: 'similar post body', createdAt: DateTime.utc(2026, 5, 23)),
  indexedAt: DateTime.utc(2026, 5, 23),
);
