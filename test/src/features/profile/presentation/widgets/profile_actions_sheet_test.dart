import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme_mode_controller.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_actions_sheet.dart';

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

class TestThemeModeNotifier extends ThemeModeController {
  TestThemeModeNotifier({required this.initial});

  final ThemeMode initial;

  @override
  ThemeMode build() => initial;
}

void main() {
  Widget buildSheet({
    required bool isCurrentUser,
    ThemeMode initialTheme = ThemeMode.dark,
    RecordingAuthNotifier? authNotifier,
  }) {
    return ProviderScope(
      overrides: [
        if (authNotifier != null) authProvider.overrideWith(() => authNotifier),
        themeModeControllerProvider.overrideWith(
          () => TestThemeModeNotifier(initial: initialTheme),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: ProfileActionsSheet(isCurrentUser: isCurrentUser)),
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
    await tester.pump();

    switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isTrue);
  });
}
