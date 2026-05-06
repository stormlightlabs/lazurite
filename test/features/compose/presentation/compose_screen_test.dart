import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeBloc extends MockBloc<ComposeEvent, ComposeState> implements ComposeBloc {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class FakeDraftsCompanion extends Fake implements DraftsCompanion {}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/lJRCiQAAAABJRU5ErkJggg==';

DraftEntry _makeDraft({int id = 1, String content = 'Draft', DateTime? scheduledAt}) => DraftEntry(
  id: id,
  accountDid: 'did:plc:test',
  content: content,
  mediaPaths: null,
  embedJson: null,
  replyUri: null,
  replyCid: null,
  rootUri: null,
  rootCid: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
  scheduledAt: scheduledAt,
);

File _writeTempImage() {
  final dir = Directory.systemTemp.createTempSync('lazurite_compose_screen_test_');
  addTearDown(() {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
  final file = File('${dir.path}/image.png');
  file.writeAsBytesSync(base64Decode(_transparentPngBase64));
  return file;
}

void main() {
  late MockComposeBloc mockBloc;
  late MockConnectivityCubit connectivityCubit;
  late MockAuthBloc authBloc;
  late MockProfileRepository profileRepository;

  setUp(() {
    registerFallbackValue(FakeDraftsCompanion());
    registerFallbackValue(const TextChanged(''));
    registerFallbackValue(
      const EditContextSet(
        postUri: 'at://did:plc:test/app.bsky.feed.post/fallback',
        postCid: 'cid-fallback',
        record: {r'$type': 'app.bsky.feed.post', 'text': 'fallback', 'createdAt': '2026-04-14T10:00:00.000Z'},
      ),
    );
    mockBloc = MockComposeBloc();
    connectivityCubit = MockConnectivityCubit();
    authBloc = MockAuthBloc();
    profileRepository = MockProfileRepository();
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
  });

  tearDown(() {
    mockBloc.close();
    authBloc.close();
  });

  Widget buildSubject({ComposeScreen screen = const ComposeScreen(), ProfileRepository? profileRepositoryOverride}) {
    Widget home = MultiBlocProvider(
      providers: [
        BlocProvider<ComposeBloc>.value(value: mockBloc),
        BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: screen,
    );

    final repository = profileRepositoryOverride;
    if (repository != null) {
      home = RepositoryProvider<ProfileRepository>.value(value: repository, child: home);
    }

    return MaterialApp(home: home);
  }

  void seedState(ComposeState state) {
    whenListen(mockBloc, Stream.value(state), initialState: state);
  }

  group('ComposeScreen', () {
    group('character counter (Bug #2)', () {
      testWidgets('shows 300 on empty compose screen', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('300'), findsOneWidget);
      });

      testWidgets('shows updated remaining count when graphemeCount changes', (tester) async {
        seedState(const ComposeState.ready(graphemeCount: 5));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('295'), findsOneWidget);
      });

      testWidgets('shows negative remaining count when over limit', (tester) async {
        seedState(const ComposeState.ready(graphemeCount: 305, isOverLimit: true));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('-5'), findsOneWidget);
      });

      testWidgets('prefills initial text and dispatches TextChanged when provided', (tester) async {
        seedState(const ComposeState.ready(text: '@river.bsky.social ', graphemeCount: 19, isEmpty: false));

        await tester.pumpWidget(buildSubject(screen: const ComposeScreen(initialText: '@river.bsky.social ')));
        await tester.pump();

        expect(find.text('@river.bsky.social '), findsOneWidget);
        verify(() => mockBloc.add(const TextChanged('@river.bsky.social '))).called(1);
      });
    });

    group('composer avatar', () {
      testWidgets('renders an initial fallback avatar', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.byKey(const ValueKey('compose_author_avatar')), findsOneWidget);
        expect(find.byType(ProfileAvatar), findsOneWidget);
      });

      testWidgets('uses authenticated display name for avatar initials', (tester) async {
        const authState = AuthState.authenticated(
          AuthTokens(accessToken: 'token', did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam'),
        );
        when(() => authBloc.state).thenReturn(authState);
        whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authState);
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('RT'), findsOneWidget);
      });

      testWidgets('loads authenticated user avatar when profile repository is available', (tester) async {
        const authState = AuthState.authenticated(
          AuthTokens(accessToken: 'token', did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam'),
        );
        when(() => authBloc.state).thenReturn(authState);
        whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authState);
        when(() => profileRepository.getProfile('did:plc:river')).thenAnswer(
          (_) async => ProfileViewDetailed(
            did: 'did:plc:river',
            handle: 'river.bsky.social',
            displayName: 'River Tam',
            avatar: 'https://example.com/avatar.jpg',
            indexedAt: DateTime.utc(2026),
          ),
        );
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject(profileRepositoryOverride: profileRepository));
        await tester.pump();

        verify(() => profileRepository.getProfile('did:plc:river')).called(1);
        expect(find.byKey(const ValueKey('compose_author_avatar')), findsOneWidget);
      });
    });

    group('edit mode', () {
      testWidgets('shows edit title, save action, and algorithm notice banner', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Updated text',
            graphemeCount: 12,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Edit Post'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(
          find.text(
            'Edits are saved by replacing the record while keeping this post URI. Ranking, counts, and visibility may '
            'shift while networks re-index.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('hides unsupported controls while editing', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Updated text',
            graphemeCount: 12,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Save Draft'), findsNothing);
        expect(find.byIcon(Icons.image_outlined), findsNothing);
        expect(find.byIcon(Icons.videocam_outlined), findsNothing);
        expect(find.byIcon(Icons.drive_file_rename_outline), findsNothing);
        expect(find.byIcon(Icons.schedule), findsNothing);
      });

      testWidgets('dispatches EditContextSet on init when edit args are provided', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Original text',
            graphemeCount: 13,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(
          buildSubject(
            screen: const ComposeScreen(
              initialText: 'Original text',
              editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
              editPostCid: 'cid-current',
              editRecord: {
                r'$type': 'app.bsky.feed.post',
                'text': 'Original text',
                'createdAt': '2026-04-14T10:00:00.000Z',
              },
            ),
          ),
        );
        await tester.pump();

        verify(
          () => mockBloc.add(
            const EditContextSet(
              postUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
              postCid: 'cid-current',
              record: {
                r'$type': 'app.bsky.feed.post',
                'text': 'Original text',
                'createdAt': '2026-04-14T10:00:00.000Z',
              },
              initialText: 'Original text',
            ),
          ),
        ).called(1);
      });
    });

    group('quote preview', () {
      testWidgets('shows quote preview with author and text when quote context exists', (tester) async {
        seedState(
          const ComposeState.ready(quoteUri: 'at://did:plc:test/app.bsky.feed.post/quoted', quoteCid: 'quoted-cid'),
        );

        await tester.pumpWidget(
          buildSubject(
            screen: const ComposeScreen(
              quoteUri: 'at://did:plc:test/app.bsky.feed.post/quoted',
              quoteCid: 'quoted-cid',
              quoteAuthorHandle: 'alice.bsky.social',
              quoteText: 'Quoted post body',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Quoting @alice.bsky.social'), findsOneWidget);
        expect(find.text('Quoted post body'), findsOneWidget);
      });

      testWidgets('remove button clears quote context', (tester) async {
        seedState(
          const ComposeState.ready(quoteUri: 'at://did:plc:test/app.bsky.feed.post/quoted', quoteCid: 'quoted-cid'),
        );

        await tester.pumpWidget(
          buildSubject(
            screen: const ComposeScreen(
              quoteUri: 'at://did:plc:test/app.bsky.feed.post/quoted',
              quoteCid: 'quoted-cid',
              quoteAuthorHandle: 'alice.bsky.social',
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byTooltip('Remove quoted post'));
        await tester.pump();

        verify(() => mockBloc.add(const QuoteContextCleared())).called(1);
      });
    });

    group('image alt text', () {
      testWidgets('shows image preview while editing alt text and saves changes', (tester) async {
        final image = _writeTempImage();
        seedState(
          ComposeState.ready(
            isEmpty: false,
            mediaAttachments: [MediaAttachment(localPath: image.path, altText: 'Existing description')],
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.text('ALT'));
        await tester.pumpAndSettle();

        expect(find.text('Alt text'), findsOneWidget);
        expect(find.byKey(const ValueKey('alt-text-image-preview')), findsOneWidget);
        expect(find.text('Existing description'), findsOneWidget);

        await tester.enterText(find.byKey(const ValueKey('alt-text-field')), 'A clearer image description');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(const AltTextUpdated(index: 0, altText: 'A clearer image description'))).called(1);
      });
    });

    group('video alt text', () {
      testWidgets('shows video preview while editing alt text and saves changes', (tester) async {
        seedState(
          const ComposeState.ready(
            isEmpty: false,
            videoAttachment: VideoAttachment(
              localPath: '/tmp/composer-video.mp4',
              status: VideoUploadStatus.ready,
              altText: 'Existing video description',
            ),
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.subtitles_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Video alt text'), findsOneWidget);
        expect(find.byKey(const ValueKey('video-alt-preview')), findsOneWidget);
        expect(find.byKey(const ValueKey('video-alt-preview-filename')), findsOneWidget);
        expect(find.text('Existing video description'), findsOneWidget);

        await tester.enterText(find.byKey(const ValueKey('video-alt-text-field')), 'A clearer video description');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(const VideoAltTextUpdated('A clearer video description'))).called(1);
      });
    });

    group('inline drafts panel (Bug #3)', () {
      testWidgets('drafts panel is hidden initially', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Drafts'), findsNothing);
      });

      testWidgets('tapping drafts button shows inline panel without BottomSheet', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Drafts'), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
      });

      testWidgets('tapping drafts button again hides panel', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Drafts'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Drafts'), findsNothing);
      });

      testWidgets('shows empty state when no drafts loaded', (tester) async {
        seedState(const ComposeState.ready().copyWith(drafts: [], isLoadingDrafts: false));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('No drafts saved'), findsOneWidget);
      });

      testWidgets('tapping save draft toolbar action fires DraftSaved', (tester) async {
        seedState(const ComposeState.ready(text: 'Save this', graphemeCount: 9, isEmpty: false));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byTooltip('Save draft'));
        await tester.pump();

        verify(() => mockBloc.add(const DraftSaved())).called(1);
      });

      testWidgets('shows draft items when drafts are loaded', (tester) async {
        seedState(
          const ComposeState.ready().copyWith(drafts: [_makeDraft(content: 'My saved draft')], isLoadingDrafts: false),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('My saved draft'), findsOneWidget);
      });

      testWidgets('shows scheduled badges in the inline draft list', (tester) async {
        seedState(
          const ComposeState.ready().copyWith(
            drafts: [_makeDraft(content: 'Scheduled draft', scheduledAt: DateTime(2026, 6, 1, 12))],
            isLoadingDrafts: false,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Scheduled draft'), findsOneWidget);
        expect(find.text('Scheduled'), findsOneWidget);
      });

      testWidgets('shows loading indicator while drafts are loading', (tester) async {
        seedState(const ComposeState.ready().copyWith(isLoadingDrafts: true));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('fires DraftsRequested when panel opens', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();

        verify(() => mockBloc.add(const DraftsRequested())).called(1);
      });

      testWidgets('tapping a draft fires DraftLoaded and closes panel', (tester) async {
        seedState(const ComposeState.ready().copyWith(drafts: [_makeDraft(id: 7, content: 'Tap to load me')]));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Tap to load me'));
        await tester.pump();

        verify(() => mockBloc.add(const DraftLoaded(7))).called(1);
        expect(find.text('Drafts'), findsNothing);
      });
    });
  });
}
