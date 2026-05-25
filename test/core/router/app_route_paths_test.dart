import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_route_paths.dart';

void main() {
  group('AppRoutePath', () {
    test('profileContextLocation encodes actor as a path segment', () {
      expect(AppRoutePath.profileContextLocation(actor: 'did:plc:abc123'), '/profile/did:plc:abc123/context');
    });
  });
}
