import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_actions_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

class RecordingAuthNotifier extends AuthNotifier {
  RecordingAuthNotifier();

  bool logoutCalled = false;

  @override
  AuthState build() {
    return AuthState.authenticated(
      Session(
        did: 'did:example',
        handle: 'example.bsky.social',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        pdsUrl: 'https://example.com',
        dpopKey: const {},
        scope: 'test',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

/// Test ThemeController that avoids Google Fonts loading.
class TestThemeController extends ThemeController {
  TestThemeController({required this.initialMode});

  final ThemeMode initialMode;

  @override
  ThemeState build() => ThemeState(
    themeMode: initialMode,
    currentPackId: 'oxocarbon',
    lightTheme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
  );
}

void main() {
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    when(
      () => mockProfileRepository.getProfile(any(), any()),
    ).thenAnswer((_) async => const ProfileData(did: 'did:plc:test', handle: 'test.bsky.social'));
    when(() => mockProfileRepository.watchProfile(any())).thenAnswer((_) => Stream.value(null));
    when(
      () => mockProfileRepository.createReport(
        reasonType: any(named: 'reasonType'),
        subjectDid: any(named: 'subjectDid'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildSheet({
    required bool isCurrentUser,
    ThemeMode initialTheme = ThemeMode.dark,
    RecordingAuthNotifier? authNotifier,
  }) {
    return ProviderScope(
      overrides: [
        if (authNotifier != null) authProvider.overrideWith(() => authNotifier),
        themeControllerProvider.overrideWith(() => TestThemeController(initialMode: initialTheme)),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ProfileActionsSheet(did: 'did:plc:test', isCurrentUser: isCurrentUser),
        ),
      ),
    );
  }

  testWidgets('shows logout option when viewing own profile', (tester) async {
    await tester.pumpWidget(buildSheet(isCurrentUser: true));
    await tester.pump();

    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('hides logout option when viewing another profile', (tester) async {
    await tester.pumpWidget(buildSheet(isCurrentUser: false));
    await tester.pump();

    expect(find.text('Log out'), findsNothing);
  });

  testWidgets('tapping logout triggers auth logout', (tester) async {
    final authNotifier = RecordingAuthNotifier();

    await tester.pumpWidget(buildSheet(isCurrentUser: true, authNotifier: authNotifier));
    await tester.pump();

    await tester.tap(find.text('Log out'));
    await tester.pump();

    expect(authNotifier.logoutCalled, isTrue);
  });

  testWidgets('switch toggles between light and dark modes', (tester) async {
    await tester.pumpWidget(buildSheet(isCurrentUser: false, initialTheme: ThemeMode.light));
    await tester.pump();

    var switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isTrue);
  });

  testWidgets('submitting report triggers repository call', (tester) async {
    await tester.pumpWidget(buildSheet(isCurrentUser: false));
    await tester.pump();

    await tester.tap(find.text('Report account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spam'));
    await tester.pump();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    verify(
      () => mockProfileRepository.createReport(
        reasonType: 'com.atproto.moderation.defs#reasonSpam',
        subjectDid: 'did:plc:test',
        reason: any(named: 'reason'),
      ),
    ).called(1);

    expect(find.text('Report submitted successfully'), findsOneWidget);
  });
}
