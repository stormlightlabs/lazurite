import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/http_method.dart';

void main() {
  group('HttpMethod', () {
    test('values contains get and post', () {
      expect(HttpMethod.values, containsAll([HttpMethod.get, HttpMethod.post]));
      expect(HttpMethod.values.length, 2);
    });

    test('get is a valid enum value', () {
      expect(HttpMethod.get.name, equals('get'));
    });

    test('post is a valid enum value', () {
      expect(HttpMethod.post.name, equals('post'));
    });
  });
}
