import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    displayName: 'River Tam',
  );

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
  });

  Widget buildSubject({required String sectionLabel, PreferredSizeWidget? bottom, List<Widget>? actions}) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        home: Scaffold(
          appBar: LazuriteAppBar(sectionLabel: sectionLabel, bottom: bottom, actions: actions),
          body: const SizedBox.shrink(),
        ),
      ),
    );
  }

  testWidgets('renders section label in uppercase', (tester) async {
    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('renders hamburger menu button', (tester) async {
    await tester.pumpWidget(buildSubject(sectionLabel: 'Search'));
    await tester.pumpAndSettle();

    expect(find.byType(AppShellMenuButton), findsOneWidget);
  });

  testWidgets('renders user initials in avatar from displayName', (tester) async {
    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    // 'River Tam' → initials 'RT'
    expect(find.text('RT'), findsOneWidget);
  });

  testWidgets('renders initials from handle when displayName is absent', (tester) async {
    authBloc = MockAuthBloc();
    const noDisplayName = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      did: 'did:plc:test',
      handle: 'alice.bsky.social',
      displayName: null,
    );
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(noDisplayName));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(noDisplayName));

    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    // handle 'alice.bsky.social' → first part 'alice.bsky.social' → 'A'
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('renders additional actions alongside avatar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        sectionLabel: 'Alerts',
        actions: [TextButton(onPressed: () {}, child: const Text('Mark All Read'))],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark All Read'), findsOneWidget);
    expect(find.text('ALERTS'), findsOneWidget);
  });

  testWidgets('preferred size height is 64 without bottom widget', (tester) async {
    const bar = LazuriteAppBar(sectionLabel: 'Home');
    expect(bar.preferredSize.height, 64);
  });

  testWidgets('preferred size height includes bottom widget height', (tester) async {
    const bottom = PreferredSize(preferredSize: Size.fromHeight(44), child: SizedBox(height: 44));
    const bar = LazuriteAppBar(sectionLabel: 'Home', bottom: bottom);
    expect(bar.preferredSize.height, 108);
  });

  testWidgets('renders bottom widget when provided', (tester) async {
    const bottom = PreferredSize(preferredSize: Size.fromHeight(44), child: Text('bottom-content'));
    await tester.pumpWidget(buildSubject(sectionLabel: 'Home', bottom: bottom));
    await tester.pumpAndSettle();

    expect(find.text('bottom-content'), findsOneWidget);
  });

  testWidgets('unauthenticated state shows default L initial', (tester) async {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());

    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    expect(find.text('L'), findsOneWidget);
  });
}
