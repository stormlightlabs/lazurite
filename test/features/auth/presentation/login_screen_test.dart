import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
  });

  Widget buildSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider<AuthBloc>.value(value: authBloc, child: const LoginScreen()),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const Scaffold(body: Text('terms-route')),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const Scaffold(body: Text('privacy-route')),
        ),
      ],
      initialLocation: '/login',
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows terms and privacy links', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: scrollable);
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('tapping Terms of Service opens terms route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('terms-route'), findsOneWidget);
  });

  testWidgets('tapping Privacy Policy opens privacy route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('privacy-route'), findsOneWidget);
  });
}
