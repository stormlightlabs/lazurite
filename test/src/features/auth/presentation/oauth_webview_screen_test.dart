import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/presentation/oauth_webview_screen.dart';

void main() {
  group('OAuthWebViewScreen', () {
    const testAuthorizeUrl = 'https://bsky.social/oauth/authorize?request_uri=test';
    const testCallbackPrefix = 'http://127.0.0.1:8080/callback';

    test('constructs with required parameters', () {
      const screen = OAuthWebViewScreen(
        authorizeUrl: testAuthorizeUrl,
        callbackUrlPrefix: testCallbackPrefix,
      );

      expect(screen.authorizeUrl, testAuthorizeUrl);
      expect(screen.callbackUrlPrefix, testCallbackPrefix);
    });
  });
}
