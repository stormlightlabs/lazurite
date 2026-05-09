import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_edit_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class _ProfileEditDraftFake extends Fake implements ProfileEditDraft {}

void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockProfileRepository profileRepository;
  late MockSettingsCubit settingsCubit;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:me',
    handle: 'me.bsky.social',
  );

  const profile = ProfileViewDetailed(
    did: 'did:plc:me',
    handle: 'me.bsky.social',
    displayName: 'River Tam',
    description: 'Signal and signal boost.',
    pronouns: 'she/her',
    website: 'river.example',
    avatar: 'https://example.com/avatar.jpg',
    banner: 'https://example.com/banner.jpg',
  );

  const settingsState = SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
  );

  setUpAll(() {
    registerFallbackValue(_ProfileEditDraftFake());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    profileRepository = MockProfileRepository();
    settingsCubit = MockSettingsCubit();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: profile));
    when(() => settingsCubit.state).thenReturn(settingsState);
    when(
      () => profileRepository.updateProfile(
        did: any(named: 'did'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async {});

    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
    whenListen(
      profileBloc,
      const Stream<ProfileState>.empty(),
      initialState: const ProfileState.loaded(profile: profile),
    );
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: settingsState);
  });

  Widget buildSubject(GoRouter router) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: RepositoryProvider<ProfileRepository>.value(
        value: profileRepository,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/profile/me/edit',
      routes: [
        GoRoute(
          path: '/profile/me',
          builder: (_, _) => const Scaffold(body: Text('profile-me')),
        ),
        GoRoute(path: '/profile/me/edit', builder: (_, _) => const ProfileEditScreen()),
      ],
    );
  }

  testWidgets('hydrates the profile edit form from the loaded profile', (tester) async {
    final router = buildRouter();

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const ValueKey('profile_edit_display_name_field'))).controller?.text,
      'River Tam',
    );
    expect(
      tester.widget<TextFormField>(find.byKey(const ValueKey('profile_edit_description_field'))).controller?.text,
      'Signal and signal boost.',
    );
    expect(
      tester.widget<TextFormField>(find.byKey(const ValueKey('profile_edit_pronouns_field'))).controller?.text,
      'she/her',
    );
    expect(
      tester.widget<TextFormField>(find.byKey(const ValueKey('profile_edit_website_field'))).controller?.text,
      'river.example',
    );
    expect(find.byTooltip('Change avatar image'), findsOneWidget);
    expect(find.byTooltip('Change banner image'), findsOneWidget);

    router.dispose();
  });

  test('profile image MIME resolver accepts only JPEG and PNG', () {
    expect(profileImageMimeTypeFor(reportedMimeType: 'image/png', path: 'anything'), 'image/png');
    expect(profileImageMimeTypeFor(reportedMimeType: 'image/jpeg', path: 'anything'), 'image/jpeg');
    expect(profileImageMimeTypeFor(reportedMimeType: null, path: '/tmp/avatar.jpg'), 'image/jpeg');
    expect(profileImageMimeTypeFor(reportedMimeType: null, path: '/tmp/avatar.jpeg'), 'image/jpeg');
    expect(profileImageMimeTypeFor(reportedMimeType: null, path: '/tmp/avatar.png'), 'image/png');
    expect(profileImageMimeTypeFor(reportedMimeType: null, path: '/tmp/avatar.gif'), isNull);
    expect(profileImageMimeTypeFor(reportedMimeType: null, path: '/tmp/avatar.webp'), isNull);
    expect(profileImageMimeTypeFor(reportedMimeType: 'image/gif', path: '/tmp/avatar.jpg'), isNull);
  });

  testWidgets('saves normalized profile edits and returns to own profile', (tester) async {
    final router = buildRouter();

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('profile_edit_display_name_field')), 'Serenity');
    await tester.enterText(find.byKey(const ValueKey('profile_edit_description_field')), 'New bio');
    await tester.enterText(find.byKey(const ValueKey('profile_edit_pronouns_field')), 'they/them');
    await tester.enterText(find.byKey(const ValueKey('profile_edit_website_field')), 'serenity.example');
    await tester.tap(find.byKey(const ValueKey('profile_edit_save_button')));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => profileRepository.updateProfile(
                did: 'did:plc:me',
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as ProfileEditDraft;
    expect(captured.displayName, 'Serenity');
    expect(captured.description, 'New bio');
    expect(captured.pronouns, 'they/them');
    expect(captured.website, 'https://serenity.example');
    verify(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me'))).called(1);
    expect(find.text('profile-me'), findsOneWidget);

    router.dispose();
  });

  testWidgets('validates website input before saving', (tester) async {
    final router = buildRouter();

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('profile_edit_website_field')), 'ftp://example.com');
    await tester.tap(find.byKey(const ValueKey('profile_edit_save_button')));
    await tester.pump();

    expect(find.text('Enter a valid website'), findsOneWidget);
    verifyNever(
      () => profileRepository.updateProfile(
        did: any(named: 'did'),
        draft: any(named: 'draft'),
      ),
    );

    router.dispose();
  });
}
