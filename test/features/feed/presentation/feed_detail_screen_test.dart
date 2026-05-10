import 'dart:async';

import 'package:poptart_core/poptart_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/feed_detail_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockFeedRepository feedRepository;
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;

  final feedUri = AtUri.parse('at://did:plc:alice/app.bsky.feed.generator/aaabbb');

  setUp(() {
    feedRepository = MockFeedRepository();
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();
    when(() => authBloc.state).thenReturn(
      const AuthState.authenticated(AuthTokens(accessToken: 'access', did: 'did:plc:me', handle: 'me.bsky.social')),
    );
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticated(
        AuthTokens(accessToken: 'access', did: 'did:plc:me', handle: 'me.bsky.social'),
      ),
    );
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      home: RepositoryProvider<FeedRepository>.value(
        value: feedRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: FeedDetailScreen(feedUri: feedUri),
        ),
      ),
    );
  }

  testWidgets('shows loading state while feed is loading', (tester) async {
    final completer = Completer<FeedResult>();
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => _generatorView(displayName: 'Discover'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(FeedResult(posts: const []));
  });

  testWidgets('shows empty state when feed has no posts', (tester) async {
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => _generatorView(displayName: 'Discover'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: const []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('No posts yet'), findsOneWidget);
  });

  testWidgets('shows feed title from generator metadata', (tester) async {
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => _generatorView(displayName: 'My Feed'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: const []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('My Feed'), findsOneWidget);
  });

  testWidgets('shows error state and supports retry', (tester) async {
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => _generatorView(displayName: 'Discover'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('boom'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Failed to load feed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => feedRepository.getFeed(feedUri: feedUri, cursor: null, limit: 50)).called(greaterThanOrEqualTo(2));
  });

  testWidgets('resolves handle actor+rkey to did-backed feed URI before loading', (tester) async {
    when(
      () => feedRepository.resolveFeedGeneratorUri(actor: 'alice.bsky.social', rkey: 'aaabbb'),
    ).thenAnswer((_) async => feedUri);
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => _generatorView(displayName: 'My Feed'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: const []));

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<FeedRepository>.value(
          value: feedRepository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
            ],
            child: const FeedDetailScreen(actor: 'alice.bsky.social', rkey: 'aaabbb'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => feedRepository.resolveFeedGeneratorUri(actor: 'alice.bsky.social', rkey: 'aaabbb')).called(1);
    verify(() => feedRepository.getFeedGenerator(feedUri)).called(1);
    verify(() => feedRepository.getFeed(feedUri: feedUri, cursor: null, limit: 50)).called(1);
  });
}

GeneratorView _generatorView({required String displayName}) {
  return GeneratorView(
    uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/discover'),
    cid: 'cid-gen',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    did: 'did:plc:creator',
    displayName: displayName,
    indexedAt: DateTime.utc(2026, 1, 1),
  );
}
