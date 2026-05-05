import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/presentation/oauth_callback_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com/oauth/callback'));
  });

  testWidgets('forwards HTTPS callback URI query params and returns to login', (tester) async {
    final authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());

    Uri? capturedUri;
    when(() => authBloc.handleOAuthRedirectUri(any())).thenAnswer((invocation) async {
      capturedUri = invocation.positionalArguments.first as Uri;
      return true;
    });

    final router = GoRouter(
      initialLocation: OAuthCallbackScreen.routePath,
      routes: [
        GoRoute(
          path: OAuthCallbackScreen.routePath,
          builder: (context, state) => OAuthCallbackScreen(
            callbackUri: Uri.parse(
              'https://lazurite.stormlightlabs.org/oauth/callback?code=abc&state=xyz&iss=https%3A%2F%2Fbsky.social',
            ),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('login')),
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => authBloc.handleOAuthRedirectUri(any())).called(1);
    expect(capturedUri, isNotNull);
    expect(capturedUri!.scheme, equals('https'));
    expect(capturedUri!.host, equals('lazurite.stormlightlabs.org'));
    expect(capturedUri!.path, equals('/oauth/callback'));
    expect(capturedUri!.queryParameters['code'], equals('abc'));
    expect(capturedUri!.queryParameters['state'], equals('xyz'));
    expect(capturedUri!.queryParameters['iss'], equals('https://bsky.social'));
    expect(find.text('login'), findsOneWidget);
  });
}
