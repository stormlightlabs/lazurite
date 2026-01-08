import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/presentation/oauth_webview_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  group('OAuthWebViewScreen', () {
    const testAuthorizeUrl = 'https://bsky.social/oauth/authorize?request_uri=test';
    const testCallbackPrefix = 'http://127.0.0.1:8080/callback';

    setUpAll(() {
      WebViewPlatform.instance = _FakeWebViewPlatform();
    });

    test('constructs with required parameters', () {
      const screen = OAuthWebViewScreen(
        authorizeUrl: testAuthorizeUrl,
        callbackUrlPrefix: testCallbackPrefix,
      );

      expect(screen.authorizeUrl, testAuthorizeUrl);
      expect(screen.callbackUrlPrefix, testCallbackPrefix);
    });

    testWidgets('renders scaffold with AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar has Sign In title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('AppBar has close button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('close button is tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      final closeButton = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(IconButton),
      );
      expect(closeButton, findsOneWidget);
    });

    testWidgets('body uses Stack layout for overlay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      final scaffoldFinder = find.byType(Scaffold);
      final stackFinder = find.descendant(of: scaffoldFinder, matching: find.byType(Stack));
      expect(stackFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('creates state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      final statefulWidget = tester.element(find.byType(OAuthWebViewScreen));
      expect(statefulWidget, isNotNull);
    });

    testWidgets('preserves authorizeUrl and callbackUrlPrefix', (tester) async {
      const customAuthorizeUrl = 'https://example.com/authorize';
      const customCallbackPrefix = 'http://localhost:3000/callback';

      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: customAuthorizeUrl,
            callbackUrlPrefix: customCallbackPrefix,
          ),
        ),
      );

      final widget = tester.widget<OAuthWebViewScreen>(find.byType(OAuthWebViewScreen));
      expect(widget.authorizeUrl, customAuthorizeUrl);
      expect(widget.callbackUrlPrefix, customCallbackPrefix);
    });

    testWidgets('close button has close icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      final closeButton = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(IconButton),
      );
      expect(closeButton, findsOneWidget);
    });

    testWidgets('loading indicator is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OAuthWebViewScreen(
            authorizeUrl: testAuthorizeUrl,
            callbackUrlPrefix: testCallbackPrefix,
          ),
        ),
      );

      final centerFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(Center),
      );
      expect(centerFinder, findsOneWidget);
    });
  });
}

/// Fake platform implementation to allow WebViewWidget to render in tests.
class _FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(PlatformWebViewWidgetCreationParams params) {
    return _FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return _FakePlatformNavigationDelegate(params);
  }
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
}

class _FakePlatformWebViewWidget extends PlatformWebViewWidget {
  _FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(key: Key('fake_webview'));
  }
}

class _FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  _FakePlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback onWebResourceError) async {}

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback onNavigationRequest) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) async {}
}
