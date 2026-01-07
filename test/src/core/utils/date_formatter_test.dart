import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatRelative returns "now" for very recent times', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now), 'now');
      expect(DateFormatter.formatRelative(now.subtract(const Duration(seconds: 30))), 'now');
    });

    test('formatRelative returns minutes', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now.subtract(const Duration(minutes: 1))), '1m');
      expect(DateFormatter.formatRelative(now.subtract(const Duration(minutes: 59))), '59m');
    });

    test('formatRelative returns hours', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now.subtract(const Duration(hours: 1))), '1h');
      expect(DateFormatter.formatRelative(now.subtract(const Duration(hours: 23))), '23h');
    });

    test('formatRelative returns days', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now.subtract(const Duration(days: 1))), '1d');
      expect(DateFormatter.formatRelative(now.subtract(const Duration(days: 6))), '6d');
    });

    test('formatRelative returns MMM d for > 7 days', () {
      final date = DateTime.now().subtract(const Duration(days: 8));
      final result = DateFormatter.formatRelative(date);
      expect(result, isNot(contains('d')));
      expect(result.length, greaterThan(3));
    });

    test('formatRelative returns yMMMd for > 365 days', () {
      final date = DateTime.now().subtract(const Duration(days: 366));
      final result = DateFormatter.formatRelative(date);
      expect(result, isNot(contains('d')));
      expect(result, contains(','));
    });
  });
}
