import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/utils/atproto_datetime.dart';

void main() {
  group('ATProto datetime utilities', () {
    test('formats UTC datetimes with millisecond precision and Z suffix', () {
      final formatted = formatAtProtoDateTime(DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513));

      expect(formatted, '2026-05-12T10:11:50.052Z');
    });

    test('formats local datetimes as UTC datetimes', () {
      final local = DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal();

      expect(formatAtProtoDateTime(local), '2026-05-12T10:11:50.052Z');
    });

    test('returns null for strings that are not datetimes', () {
      expect(formatAtProtoDateTimeString('not-a-date'), isNull);
    });

    test('canonicalizes datetimes to UTC with microseconds truncated', () {
      final canonical = canonicalAtProtoDateTime(DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal());

      expect(canonical, DateTime.utc(2026, 5, 12, 10, 11, 50, 52));
      expect(canonical.microsecond, 0);
    });
  });
}
