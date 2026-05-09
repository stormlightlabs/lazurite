// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:bluesky_text/bluesky_text.dart';

void main() {
  test('init', () {
    const config = LinkConfig();

    expect(config.excludeProtocol, isFalse);
    expect(config.enableShortening, isFalse);
  });

  test('with excludeProtocol', () {
    const config = LinkConfig(excludeProtocol: true);

    expect(config.excludeProtocol, isTrue);
    expect(config.enableShortening, isFalse);
  });

  test('with maxGraphemeLength', () {
    const config = LinkConfig(enableShortening: true);

    expect(config.excludeProtocol, isFalse);
    expect(config.enableShortening, isTrue);
  });
}
